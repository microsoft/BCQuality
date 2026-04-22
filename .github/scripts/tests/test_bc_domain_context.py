#!/usr/bin/env python3
"""
Tests for the bc-domain-context reference implementation.

Run with: python -m unittest .github.scripts.tests.test_bc_domain_context
Or:      cd .github/scripts/tests && python -m unittest test_bc_domain_context

The tests build fixture knowledge trees in tempfile directories and exercise
the skill's Source / Relevance / Worklist / Action pipeline end to end.
"""
from __future__ import annotations

import os
import sys
import tempfile
import textwrap
import unittest
from pathlib import Path

# Add the scripts directory (parent of tests/) to sys.path so we can import
# bc_domain_context.py.
_SCRIPTS_DIR = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(_SCRIPTS_DIR))

from bc_domain_context import run_bc_domain_context  # noqa: E402


def _write(
    root: Path,
    layer: str,
    domain: str,
    slug: str,
    *,
    bc_version: str = "[26..28]",
    technologies: str = "[al]",
    countries: str = "[w1]",
    application_area: str | None = None,
    keywords: str = "[sample]",
    domain_value: str | None = None,
    description: str = "Short description. Another sentence.",
    title: str | None = None,
) -> Path:
    """Write a fixture knowledge file and return its path."""
    if application_area is None:
        application_area = f"[{domain}]"
    if domain_value is None:
        domain_value = domain
    if title is None:
        title = slug.replace("-", " ").capitalize()
    target = root / layer / "knowledge" / domain / f"{slug}.md"
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(
        textwrap.dedent(
            f"""\
            ---
            bc-version: {bc_version}
            domain: {domain_value}
            keywords: {keywords}
            technologies: {technologies}
            countries: {countries}
            application-area: {application_area}
            ---

            # {title}

            ## Description

            {description}
            """
        ),
        encoding="utf-8",
    )
    return target


class BcDomainContextTests(unittest.TestCase):
    def setUp(self):
        self._tmp = tempfile.TemporaryDirectory()
        self.root = Path(self._tmp.name)
        self.addCleanup(self._tmp.cleanup)

    # --- Core filtering ---

    def test_filter_by_area_returns_only_requested_area(self):
        _write(self.root, "microsoft", "finance", "chart-of-accounts")
        _write(self.root, "microsoft", "finance", "general-ledger-entries")
        _write(self.root, "microsoft", "finance", "dimensions")
        _write(self.root, "microsoft", "sales", "order-to-cash")
        _write(self.root, "microsoft", "sales", "pricing")

        report = run_bc_domain_context(self.root, {
            "application-area": ["finance"],
            "technologies": ["al"],
            "bc-version": 28,
            "countries": ["w1"],
        })

        self.assertEqual(report["outcome"], "completed")
        paths = sorted(f["id"] for f in report["findings"])
        self.assertEqual(paths, [
            "microsoft/knowledge/finance/chart-of-accounts.md",
            "microsoft/knowledge/finance/dimensions.md",
            "microsoft/knowledge/finance/general-ledger-entries.md",
        ])
        for finding in report["findings"]:
            self.assertEqual(finding["severity"], "info")
            self.assertEqual(finding["confidence"], "high")

    def test_application_area_all_returns_union(self):
        _write(self.root, "microsoft", "finance", "chart-of-accounts")
        _write(self.root, "microsoft", "sales", "order-to-cash")
        _write(self.root, "microsoft", "manufacturing", "bom")

        report = run_bc_domain_context(self.root, {
            "application-area": ["all"],
            "technologies": ["al"],
            "bc-version": 28,
            "countries": ["w1"],
        })

        self.assertEqual(report["outcome"], "completed")
        self.assertEqual(len(report["findings"]), 3)
        paths = {f["id"] for f in report["findings"]}
        self.assertIn("microsoft/knowledge/finance/chart-of-accounts.md", paths)
        self.assertIn("microsoft/knowledge/sales/order-to-cash.md", paths)
        self.assertIn("microsoft/knowledge/manufacturing/bom.md", paths)

    def test_technologies_mismatch_drops_file(self):
        _write(self.root, "microsoft", "finance", "al-concept")
        _write(
            self.root,
            "microsoft",
            "finance",
            "kql-only-concept",
            technologies="[kql]",
        )

        report = run_bc_domain_context(self.root, {
            "application-area": ["finance"],
            "technologies": ["al"],
            "bc-version": 28,
            "countries": ["w1"],
        })

        paths = {f["id"] for f in report["findings"]}
        self.assertIn("microsoft/knowledge/finance/al-concept.md", paths)
        self.assertNotIn("microsoft/knowledge/finance/kql-only-concept.md", paths)

    def test_no_matching_knowledge_returns_not_applicable(self):
        _write(self.root, "microsoft", "finance", "chart-of-accounts")

        report = run_bc_domain_context(self.root, {
            "application-area": ["manufacturing"],
            "technologies": ["al"],
            "bc-version": 28,
            "countries": ["w1"],
        })

        self.assertEqual(report["outcome"], "no-knowledge")
        self.assertEqual(report["findings"], [])

    # --- Layer precedence ---

    def test_layer_precedence_microsoft_wins_over_community(self):
        _write(self.root, "community", "finance", "vat-on-prepayment")
        _write(self.root, "microsoft", "finance", "vat-on-prepayment")

        report = run_bc_domain_context(self.root, {
            "application-area": ["finance"],
            "technologies": ["al"],
            "bc-version": 28,
            "countries": ["w1"],
        })

        paths = [f["id"] for f in report["findings"]]
        self.assertEqual(
            paths, ["microsoft/knowledge/finance/vat-on-prepayment.md"]
        )
        suppressed_paths = [s["reference"]["path"] for s in report["suppressed"]]
        self.assertEqual(
            suppressed_paths,
            ["community/knowledge/finance/vat-on-prepayment.md"],
        )
        self.assertEqual(report["suppressed"][0]["reason"], "layer-precedence")

    def test_layer_precedence_custom_wins_over_microsoft(self):
        _write(self.root, "microsoft", "finance", "vat-on-prepayment")
        _write(self.root, "custom", "finance", "vat-on-prepayment")

        report = run_bc_domain_context(self.root, {
            "application-area": ["finance"],
            "technologies": ["al"],
            "bc-version": 28,
            "countries": ["w1"],
        })

        paths = [f["id"] for f in report["findings"]]
        self.assertEqual(
            paths, ["custom/knowledge/finance/vat-on-prepayment.md"]
        )

    # --- Conditional applicability (unknown dimensions) ---

    def test_unknown_bc_version_caps_confidence_at_medium(self):
        _write(self.root, "microsoft", "finance", "chart-of-accounts")
        _write(self.root, "microsoft", "finance", "dimensions")

        # bc-version omitted from task-context.
        report = run_bc_domain_context(self.root, {
            "application-area": ["finance"],
            "technologies": ["al"],
            "countries": ["w1"],
        })

        self.assertTrue(report["findings"])
        for finding in report["findings"]:
            self.assertEqual(finding["confidence"], "medium")
            self.assertIn("bc-version", finding["message"])

    # --- Goal-directed narrowing ---

    def test_goal_tokens_narrow_worklist(self):
        _write(
            self.root,
            "microsoft",
            "finance",
            "vat-on-prepayment-chains",
            keywords="[vat, prepayment, credit-memo]",
        )
        _write(
            self.root,
            "microsoft",
            "finance",
            "dimensions",
            keywords="[dimensions, default-priority]",
        )
        _write(
            self.root,
            "microsoft",
            "finance",
            "chart-of-accounts",
            keywords="[chart, account]",
        )

        report = run_bc_domain_context(self.root, {
            "goal": "bc-domain-context for finance — VAT wrong on prepayment credit memo",
            "application-area": ["finance"],
            "technologies": ["al"],
            "bc-version": 28,
            "countries": ["w1"],
        })

        paths = [f["id"] for f in report["findings"]]
        self.assertIn(
            "microsoft/knowledge/finance/vat-on-prepayment-chains.md",
            paths,
        )
        # The highest-scoring file should come first.
        self.assertEqual(
            paths[0],
            "microsoft/knowledge/finance/vat-on-prepayment-chains.md",
        )

    def test_generic_goal_keeps_full_area(self):
        _write(self.root, "microsoft", "finance", "chart-of-accounts")
        _write(self.root, "microsoft", "finance", "dimensions")

        report = run_bc_domain_context(self.root, {
            "goal": "bc-domain-context for finance",
            "application-area": ["finance"],
            "technologies": ["al"],
            "bc-version": 28,
            "countries": ["w1"],
        })

        self.assertEqual(len(report["findings"]), 2)

    # --- Layer disabling ---

    def test_disabled_layer_is_invisible(self):
        _write(self.root, "community", "finance", "only-in-community")
        _write(self.root, "microsoft", "finance", "only-in-microsoft")

        report = run_bc_domain_context(self.root, {
            "application-area": ["finance"],
            "technologies": ["al"],
            "bc-version": 28,
            "countries": ["w1"],
            "enabled-layers": ["microsoft"],
        })

        paths = [f["id"] for f in report["findings"]]
        self.assertEqual(paths, ["microsoft/knowledge/finance/only-in-microsoft.md"])


if __name__ == "__main__":
    unittest.main()
