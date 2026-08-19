int jsonInt(Object? value) => (value as num?)?.toInt() ?? 0;

String jsonString(Object? value) => value?.toString() ?? '';

bool jsonBool(Object? value) =>
    value == true || value == 1 || value == '1' || value == 'true';

int jsonTimeout(Object? value) => (value as num?)?.toInt() ?? 30;
