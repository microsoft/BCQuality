"""Validate knowledge-response examples and reject unsafe citation shapes."""
import copy
import json
from pathlib import Path

from jsonschema import Draft7Validator

ROOT = Path(__file__).resolve().parents[2]
schema = json.loads((ROOT / 'schemas/knowledge-response.schema.json').read_text())
Draft7Validator.check_schema(schema)
validator = Draft7Validator(schema)
base = {
    'skill': {'id': 'al-knowledge', 'version': 1},
    'outcome': 'completed', 'question': 'When is SetLoadFields useful?',
    'answer': 'Use it for partial records under the cited conditions.',
    'references': [{
        'path': 'microsoft/knowledge/performance/use-setloadfields-for-partial-records.md',
        'applicability': 'conditional', 'unknown': ['bc-version'],
    }], 'suppressed': [],
}
assert (ROOT / base['references'][0]['path']).is_file()
cases = 0


def check(value, valid):
    global cases
    errors = list(validator.iter_errors(value))
    assert bool(errors) != valid, [error.message for error in errors]
    cases += 1


check(base, True)
value = copy.deepcopy(base)
value['references'][0]['unknown'] = []
check(value, False)
value['references'][0]['applicability'] = 'applicable'
check(value, True)
value['references'][0]['unknown'] = ['bc-version']
check(value, False)
for outcome in ('failed', 'no-knowledge'):
    value = copy.deepcopy(base)
    value.update(outcome=outcome, **{'outcome-reason': 'No usable knowledge'})
    check(value, False)
    value['references'] = []
    check(value, True)
value = copy.deepcopy(base)
value['references'] = []
check(value, False)
value = copy.deepcopy(base)
value['outcome'] = 'partial'
check(value, False)
value['outcome-reason'] = 'Target version is unknown'
check(value, True)
value = copy.deepcopy(base)
value['references'][0]['path'] = 'invented/article.md'
check(value, False)
print(f'Knowledge-response schema: {cases} positive/negative cases passed.')
