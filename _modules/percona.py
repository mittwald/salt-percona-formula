import salt.modules.mysql
import salt.exceptions
import salt.utils
import logging

try:
    import MySQLdb
    HAS_MYSQL = True
except ImportError:
    HAS_MYSQL = False

log = logging.getLogger(__name__)


def __virtual__():
    return HAS_MYSQL


def setglobal(name, value, fail_on_readonly=True, **connection_args):
    name = __salt__['mysql.quote_identifier'](name)

    if isinstance(value, int):
        query = 'SET GLOBAL %s = %d' % (name, value)
    elif isinstance(value, bool):
        query = 'SET GLOBAL %s = %r' % (name, value)
    else:
        value = MySQLdb.escape_string(str(value))
        query = 'SET GLOBAL %s = "%s"' % (name, value)


    result = __salt__['mysql.query']('mysql', query, **connection_args)
    if len(result) == 0 and 'mysql.error' in __context__:
        err = __context__['mysql.error']
        del(__context__['mysql.error'])
        is_readonly = '1238' in err
        is_query_cache_type = '1651' in err

        if is_readonly:
            if fail_on_readonly:
                raise Exception('Cannot set read-only global variable %s: %s' % (name, err))
            else:
                logging.warning('Variable %s is read-only' % name)
                return 'readonly'
        elif is_query_cache_type:
            if fail_on_readonly:
                raise Exception('Cannot enable variable %s dynamically: %s' % (name, err))
            else:
                logging.warning('Variable %s cannot be enabled dynamically: %s' % (name, err))
                return 'query_cache_type'

        raise Exception('Cannot set global variable %s: %s' % (name, err))

    return True


def getglobal(name, **connection_args):
    result = __salt__['mysql.showglobal'](**connection_args)
    for var in result:
        if var['Variable_name'] == name:
            return var['Value']
    return None


def getglobalnames(**connection_args):
    result = __salt__['mysql.showglobal'](**connection_args)
    return [var['Variable_name'] for var in result]


def hasglobal(name, **connection_args):
    result = __salt__['mysql.showglobal'](**connection_args)
    for var in result:
        if var['Variable_name'] == name:
            return True
    return False
