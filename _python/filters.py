def dateformat(value, format="%d-%b-%Y"):
    return value.strftime(format)


def datetimeformat(value, format="%d-%b-%Y %H:%M"):
    return value.strftime(format)

filters = {}
filters['dateformat'] = dateformat
filters['datetimeformat'] = datetimeformat
