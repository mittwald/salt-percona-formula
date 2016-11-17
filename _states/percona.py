import salt.utils
import logging

log = logging.getLogger(__name__)


def __virtual__():
    return 'percona.setglobal' in __salt__


def _str_to_bool(value):
    if value.lower() in ('yes', 'true', 'on'):
        return True
    elif value.lower() in ('no', 'false', 'off'):
        return False
    return value

def _accept_int_as_bool(value):
    if isinstance(value, int) and value == 1:
        return True
    elif isinstance(value, int) and value == 0:
        return False
    return value


def setglobal(name, value, fail_on_missing=True, fail_on_readonly=True, **connection_args):
    if not __salt__['percona.hasglobal'](name, **connection_args):
        return {'name': name,
                'changes': {},
                'result': not fail_on_missing,
                'comment': 'Variable {0} does not exist'.format(name)}

    ret = {'name': name,
           'changes': {},
           'result': True,
           'comment': 'Variable {0} is already set'.format(name)}

    existing_value = __salt__['percona.getglobal'](name, **connection_args)
    if isinstance(_str_to_bool(existing_value.lower()), bool):
        if _str_to_bool(existing_value.lower()) == _accept_int_as_bool(value):
            return ret
    elif _str_to_bool(existing_value.lower()) == _str_to_bool(str(value).lower()):
        return ret

    ret['comment'] = 'Set variable %s to %s' % (name, value)
    ret['changes']['value'] = {
        'before': existing_value,
        'now': str(value)
    }

    if __opts__['test']:
        ret['result'] = None
        ret['comment'] = 'Would set variable %s to %s' % (name, value)
        return ret

    try:
        result = __salt__['percona.setglobal'](name, value, fail_on_readonly=False, **connection_args)
        if not result:
            ret['comment'] = 'Variable %s is read-only' % name
            ret['changes'] = {}
            ret['result'] = False if fail_on_readonly else None
        else:
            ret['result'] = True
    except Exception as e:
        ret['result'] = False
        ret['comment'] = str(e)
        ret['changes'] = {}

    return ret
