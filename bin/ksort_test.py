from __future__ import unicode_literals, print_function, absolute_import

__requirements__ = ('intensional',)

import pytest
#from .ksort import parse_size_value



from intensional import Re

SIZE_VALUE_PATTERN = Re(r'^(\d+(?:\.\d*)?)([bkmgt]?)i?b?$', Re.I)
_SIZE_PREFIX_MAGNITUDE = {
    '': 1,
    'b': 1,
    'k': 1024,
    'm': 1024 ** 2,
    'g': 1024 ** 3,
    't': 1024 ** 4,
    }
def parse_size_value(s):
    if s not in SIZE_VALUE_PATTERN:
        raise ValueError('Not a size-like value: {}'.format(s))
    value = float(Re._[1])
    unit_prefix = Re._[2].lower()
    return int(value * _SIZE_PREFIX_MAGNITUDE[unit_prefix])





class TestsParseSizeValue(object):
    @pytest.mark.parametrize(('s', 'expected'), [
        ('112Gi', 112 * (1024 ** 3)),
        ('42', 42),
        ('1.2k', 1.2 * 1024),
        ('3MiB', 3 * (1024 ** 2)),
        ])
    def test_parse_result(self, s, expected):
        expected = int(expected)
        result = parse_size_value(s)
        assert result == expected
