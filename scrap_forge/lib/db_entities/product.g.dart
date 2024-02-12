// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetProductCollection on Isar {
  IsarCollection<Product> get products => this.collection();
}

const ProductSchema = CollectionSchema(
  name: r'Product',
  id: -6222113721139403729,
  properties: {
    r'available': PropertySchema(
      id: 0,
      name: r'available',
      type: IsarType.long,
    ),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.string,
    ),
    r'consumed': PropertySchema(
      id: 2,
      name: r'consumed',
      type: IsarType.long,
    ),
    r'count': PropertySchema(
      id: 3,
      name: r'count',
      type: IsarType.long,
    ),
    r'description': PropertySchema(
      id: 4,
      name: r'description',
      type: IsarType.string,
    ),
    r'dimensions': PropertySchema(
      id: 5,
      name: r'dimensions',
      type: IsarType.object,
      target: r'Dimensions',
    ),
    r'finishedTimestamp': PropertySchema(
      id: 6,
      name: r'finishedTimestamp',
      type: IsarType.long,
    ),
    r'heightmm': PropertySchema(
      id: 7,
      name: r'heightmm',
      type: IsarType.double,
    ),
    r'lastModifiedTimestamp': PropertySchema(
      id: 8,
      name: r'lastModifiedTimestamp',
      type: IsarType.long,
    ),
    r'lengthmm': PropertySchema(
      id: 9,
      name: r'lengthmm',
      type: IsarType.double,
    ),
    r'maxArea': PropertySchema(
      id: 10,
      name: r'maxArea',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 11,
      name: r'name',
      type: IsarType.string,
    ),
    r'needed': PropertySchema(
      id: 12,
      name: r'needed',
      type: IsarType.long,
    ),
    r'photos': PropertySchema(
      id: 13,
      name: r'photos',
      type: IsarType.stringList,
    ),
    r'progress': PropertySchema(
      id: 14,
      name: r'progress',
      type: IsarType.string,
      enumMap: _ProductprogressEnumValueMap,
    ),
    r'projectionAreamm': PropertySchema(
      id: 15,
      name: r'projectionAreamm',
      type: IsarType.double,
    ),
    r'startedTimestamp': PropertySchema(
      id: 16,
      name: r'startedTimestamp',
      type: IsarType.long,
    ),
    r'volume': PropertySchema(
      id: 17,
      name: r'volume',
      type: IsarType.double,
    ),
    r'widthmm': PropertySchema(
      id: 18,
      name: r'widthmm',
      type: IsarType.double,
    )
  },
  estimateSize: _productEstimateSize,
  serialize: _productSerialize,
  deserialize: _productDeserialize,
  deserializeProp: _productDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'madeFrom': LinkSchema(
      id: 3338612161385220881,
      name: r'madeFrom',
      target: r'Product',
      single: false,
    ),
    r'usedIn': LinkSchema(
      id: 3175565128530135166,
      name: r'usedIn',
      target: r'Product',
      single: false,
      linkName: r'madeFrom',
    )
  },
  embeddedSchemas: {r'Dimensions': DimensionsSchema},
  getId: _productGetId,
  getLinks: _productGetLinks,
  attach: _productAttach,
  version: '3.1.0+1',
);

int _productEstimateSize(
  Product object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.category;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.dimensions;
    if (value != null) {
      bytesCount += 3 +
          DimensionsSchema.estimateSize(
              value, allOffsets[Dimensions]!, allOffsets);
    }
  }
  {
    final value = object.name;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.photos.length * 3;
  {
    for (var i = 0; i < object.photos.length; i++) {
      final value = object.photos[i];
      bytesCount += value.length * 3;
    }
  }
  {
    final value = object.progress;
    if (value != null) {
      bytesCount += 3 + value.name.length * 3;
    }
  }
  return bytesCount;
}

void _productSerialize(
  Product object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.available);
  writer.writeString(offsets[1], object.category);
  writer.writeLong(offsets[2], object.consumed);
  writer.writeLong(offsets[3], object.count);
  writer.writeString(offsets[4], object.description);
  writer.writeObject<Dimensions>(
    offsets[5],
    allOffsets,
    DimensionsSchema.serialize,
    object.dimensions,
  );
  writer.writeLong(offsets[6], object.finishedTimestamp);
  writer.writeDouble(offsets[7], object.heightmm);
  writer.writeLong(offsets[8], object.lastModifiedTimestamp);
  writer.writeDouble(offsets[9], object.lengthmm);
  writer.writeDouble(offsets[10], object.maxArea);
  writer.writeString(offsets[11], object.name);
  writer.writeLong(offsets[12], object.needed);
  writer.writeStringList(offsets[13], object.photos);
  writer.writeString(offsets[14], object.progress?.name);
  writer.writeDouble(offsets[15], object.projectionAreamm);
  writer.writeLong(offsets[16], object.startedTimestamp);
  writer.writeDouble(offsets[17], object.volume);
  writer.writeDouble(offsets[18], object.widthmm);
}

Product _productDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Product();
  object.available = reader.readLongOrNull(offsets[0]);
  object.category = reader.readStringOrNull(offsets[1]);
  object.consumed = reader.readLongOrNull(offsets[2]);
  object.count = reader.readLongOrNull(offsets[3]);
  object.description = reader.readStringOrNull(offsets[4]);
  object.dimensions = reader.readObjectOrNull<Dimensions>(
    offsets[5],
    DimensionsSchema.deserialize,
    allOffsets,
  );
  object.finishedTimestamp = reader.readLongOrNull(offsets[6]);
  object.id = id;
  object.lastModifiedTimestamp = reader.readLongOrNull(offsets[8]);
  object.name = reader.readStringOrNull(offsets[11]);
  object.needed = reader.readLongOrNull(offsets[12]);
  object.photos = reader.readStringList(offsets[13]) ?? [];
  object.progress =
      _ProductprogressValueEnumMap[reader.readStringOrNull(offsets[14])];
  object.startedTimestamp = reader.readLongOrNull(offsets[16]);
  return object;
}

P _productDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readLongOrNull(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readObjectOrNull<Dimensions>(
        offset,
        DimensionsSchema.deserialize,
        allOffsets,
      )) as P;
    case 6:
      return (reader.readLongOrNull(offset)) as P;
    case 7:
      return (reader.readDouble(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset)) as P;
    case 9:
      return (reader.readDouble(offset)) as P;
    case 10:
      return (reader.readDouble(offset)) as P;
    case 11:
      return (reader.readStringOrNull(offset)) as P;
    case 12:
      return (reader.readLongOrNull(offset)) as P;
    case 13:
      return (reader.readStringList(offset) ?? []) as P;
    case 14:
      return (_ProductprogressValueEnumMap[reader.readStringOrNull(offset)])
          as P;
    case 15:
      return (reader.readDouble(offset)) as P;
    case 16:
      return (reader.readLongOrNull(offset)) as P;
    case 17:
      return (reader.readDouble(offset)) as P;
    case 18:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _ProductprogressEnumValueMap = {
  r'finished': r'finished',
  r'inProgress': r'inProgress',
  r'planned': r'planned',
};
const _ProductprogressValueEnumMap = {
  r'finished': ProjectLifeCycle.finished,
  r'inProgress': ProjectLifeCycle.inProgress,
  r'planned': ProjectLifeCycle.planned,
};

Id _productGetId(Product object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _productGetLinks(Product object) {
  return [object.madeFrom, object.usedIn];
}

void _productAttach(IsarCollection<dynamic> col, Id id, Product object) {
  object.id = id;
  object.madeFrom.attach(col, col.isar.collection<Product>(), r'madeFrom', id);
  object.usedIn.attach(col, col.isar.collection<Product>(), r'usedIn', id);
}

extension ProductQueryWhereSort on QueryBuilder<Product, Product, QWhere> {
  QueryBuilder<Product, Product, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension ProductQueryWhere on QueryBuilder<Product, Product, QWhereClause> {
  QueryBuilder<Product, Product, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Product, Product, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Product, Product, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Product, Product, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ProductQueryFilter
    on QueryBuilder<Product, Product, QFilterCondition> {
  QueryBuilder<Product, Product, QAfterFilterCondition> availableIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'available',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> availableIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'available',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> availableEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'available',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> availableGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'available',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> availableLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'available',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> availableBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'available',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'category',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'category',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> consumedIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'consumed',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> consumedIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'consumed',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> consumedEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consumed',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> consumedGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consumed',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> consumedLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consumed',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> consumedBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consumed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> countIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'count',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> countIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'count',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> countEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> countGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> countLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'count',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> countBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'count',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> dimensionsIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'dimensions',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> dimensionsIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'dimensions',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      finishedTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'finishedTimestamp',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      finishedTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'finishedTimestamp',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      finishedTimestampEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'finishedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      finishedTimestampGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'finishedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      finishedTimestampLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'finishedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      finishedTimestampBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'finishedTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> heightmmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heightmm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> heightmmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heightmm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> heightmmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heightmm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> heightmmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heightmm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      lastModifiedTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastModifiedTimestamp',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      lastModifiedTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastModifiedTimestamp',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      lastModifiedTimestampEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastModifiedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      lastModifiedTimestampGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastModifiedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      lastModifiedTimestampLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastModifiedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      lastModifiedTimestampBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastModifiedTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> lengthmmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lengthmm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> lengthmmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lengthmm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> lengthmmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lengthmm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> lengthmmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lengthmm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> maxAreaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'maxArea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> maxAreaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'maxArea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> maxAreaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'maxArea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> maxAreaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'maxArea',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'name',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> neededIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'needed',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> neededIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'needed',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> neededEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'needed',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> neededGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'needed',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> neededLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'needed',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> neededBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'needed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      photosElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photos',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photos',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photos',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photos',
        value: '',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      photosElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photos',
        value: '',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photos',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photos',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photos',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photos',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photos',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> photosLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'photos',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'progress',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'progress',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressEqualTo(
    ProjectLifeCycle? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressGreaterThan(
    ProjectLifeCycle? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'progress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressLessThan(
    ProjectLifeCycle? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'progress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressBetween(
    ProjectLifeCycle? lower,
    ProjectLifeCycle? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'progress',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'progress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'progress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'progress',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'progress',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'progress',
        value: '',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> progressIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'progress',
        value: '',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> projectionAreammEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectionAreamm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      projectionAreammGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectionAreamm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      projectionAreammLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectionAreamm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> projectionAreammBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectionAreamm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      startedTimestampIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startedTimestamp',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      startedTimestampIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startedTimestamp',
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> startedTimestampEqualTo(
      int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      startedTimestampGreaterThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      startedTimestampLessThan(
    int? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startedTimestamp',
        value: value,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> startedTimestampBetween(
    int? lower,
    int? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startedTimestamp',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> volumeEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> volumeGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> volumeLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'volume',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> volumeBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'volume',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> widthmmEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'widthmm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> widthmmGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'widthmm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> widthmmLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'widthmm',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> widthmmBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'widthmm',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension ProductQueryObject
    on QueryBuilder<Product, Product, QFilterCondition> {
  QueryBuilder<Product, Product, QAfterFilterCondition> dimensions(
      FilterQuery<Dimensions> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'dimensions');
    });
  }
}

extension ProductQueryLinks
    on QueryBuilder<Product, Product, QFilterCondition> {
  QueryBuilder<Product, Product, QAfterFilterCondition> madeFrom(
      FilterQuery<Product> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'madeFrom');
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> madeFromLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'madeFrom', length, true, length, true);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> madeFromIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'madeFrom', 0, true, 0, true);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> madeFromIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'madeFrom', 0, false, 999999, true);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> madeFromLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'madeFrom', 0, true, length, include);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition>
      madeFromLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'madeFrom', length, include, 999999, true);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> madeFromLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'madeFrom', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> usedIn(
      FilterQuery<Product> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'usedIn');
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> usedInLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'usedIn', length, true, length, true);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> usedInIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'usedIn', 0, true, 0, true);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> usedInIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'usedIn', 0, false, 999999, true);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> usedInLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'usedIn', 0, true, length, include);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> usedInLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'usedIn', length, include, 999999, true);
    });
  }

  QueryBuilder<Product, Product, QAfterFilterCondition> usedInLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'usedIn', lower, includeLower, upper, includeUpper);
    });
  }
}

extension ProductQuerySortBy on QueryBuilder<Product, Product, QSortBy> {
  QueryBuilder<Product, Product, QAfterSortBy> sortByAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'available', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByAvailableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'available', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumed', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByConsumedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumed', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByFinishedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedTimestamp', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByFinishedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedTimestamp', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByHeightmm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightmm', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByHeightmmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightmm', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByLastModifiedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedTimestamp', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy>
      sortByLastModifiedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedTimestamp', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByLengthmm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lengthmm', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByLengthmmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lengthmm', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByMaxArea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxArea', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByMaxAreaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxArea', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByNeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needed', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByNeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needed', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByProjectionAreamm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectionAreamm', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByProjectionAreammDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectionAreamm', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByStartedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedTimestamp', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByStartedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedTimestamp', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByWidthmm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widthmm', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> sortByWidthmmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widthmm', Sort.desc);
    });
  }
}

extension ProductQuerySortThenBy
    on QueryBuilder<Product, Product, QSortThenBy> {
  QueryBuilder<Product, Product, QAfterSortBy> thenByAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'available', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByAvailableDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'available', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumed', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByConsumedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumed', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'count', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByFinishedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedTimestamp', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByFinishedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'finishedTimestamp', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByHeightmm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightmm', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByHeightmmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heightmm', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByLastModifiedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedTimestamp', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy>
      thenByLastModifiedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastModifiedTimestamp', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByLengthmm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lengthmm', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByLengthmmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lengthmm', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByMaxArea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxArea', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByMaxAreaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'maxArea', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByNeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needed', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByNeededDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'needed', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'progress', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByProjectionAreamm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectionAreamm', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByProjectionAreammDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'projectionAreamm', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByStartedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedTimestamp', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByStartedTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startedTimestamp', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByVolumeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'volume', Sort.desc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByWidthmm() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widthmm', Sort.asc);
    });
  }

  QueryBuilder<Product, Product, QAfterSortBy> thenByWidthmmDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'widthmm', Sort.desc);
    });
  }
}

extension ProductQueryWhereDistinct
    on QueryBuilder<Product, Product, QDistinct> {
  QueryBuilder<Product, Product, QDistinct> distinctByAvailable() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'available');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByConsumed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consumed');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'count');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByFinishedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'finishedTimestamp');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByHeightmm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heightmm');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByLastModifiedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastModifiedTimestamp');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByLengthmm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lengthmm');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByMaxArea() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'maxArea');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByNeeded() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'needed');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByPhotos() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photos');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByProgress(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'progress', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByProjectionAreamm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'projectionAreamm');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByStartedTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startedTimestamp');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByVolume() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'volume');
    });
  }

  QueryBuilder<Product, Product, QDistinct> distinctByWidthmm() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'widthmm');
    });
  }
}

extension ProductQueryProperty
    on QueryBuilder<Product, Product, QQueryProperty> {
  QueryBuilder<Product, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Product, int?, QQueryOperations> availableProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'available');
    });
  }

  QueryBuilder<Product, String?, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<Product, int?, QQueryOperations> consumedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consumed');
    });
  }

  QueryBuilder<Product, int?, QQueryOperations> countProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'count');
    });
  }

  QueryBuilder<Product, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Product, Dimensions?, QQueryOperations> dimensionsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'dimensions');
    });
  }

  QueryBuilder<Product, int?, QQueryOperations> finishedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'finishedTimestamp');
    });
  }

  QueryBuilder<Product, double, QQueryOperations> heightmmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heightmm');
    });
  }

  QueryBuilder<Product, int?, QQueryOperations>
      lastModifiedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastModifiedTimestamp');
    });
  }

  QueryBuilder<Product, double, QQueryOperations> lengthmmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lengthmm');
    });
  }

  QueryBuilder<Product, double, QQueryOperations> maxAreaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'maxArea');
    });
  }

  QueryBuilder<Product, String?, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Product, int?, QQueryOperations> neededProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'needed');
    });
  }

  QueryBuilder<Product, List<String>, QQueryOperations> photosProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photos');
    });
  }

  QueryBuilder<Product, ProjectLifeCycle?, QQueryOperations>
      progressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'progress');
    });
  }

  QueryBuilder<Product, double, QQueryOperations> projectionAreammProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'projectionAreamm');
    });
  }

  QueryBuilder<Product, int?, QQueryOperations> startedTimestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startedTimestamp');
    });
  }

  QueryBuilder<Product, double, QQueryOperations> volumeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'volume');
    });
  }

  QueryBuilder<Product, double, QQueryOperations> widthmmProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'widthmm');
    });
  }
}

// **************************************************************************
// IsarEmbeddedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

const DimensionsSchema = Schema(
  name: r'Dimensions',
  id: -8541998787833482581,
  properties: {
    r'areaDisplayUnit': PropertySchema(
      id: 0,
      name: r'areaDisplayUnit',
      type: IsarType.int,
      enumMap: _DimensionsareaDisplayUnitEnumValueMap,
    ),
    r'height': PropertySchema(
      id: 1,
      name: r'height',
      type: IsarType.double,
    ),
    r'heightDisplayUnit': PropertySchema(
      id: 2,
      name: r'heightDisplayUnit',
      type: IsarType.int,
      enumMap: _DimensionsheightDisplayUnitEnumValueMap,
    ),
    r'length': PropertySchema(
      id: 3,
      name: r'length',
      type: IsarType.double,
    ),
    r'lengthDisplayUnit': PropertySchema(
      id: 4,
      name: r'lengthDisplayUnit',
      type: IsarType.int,
      enumMap: _DimensionslengthDisplayUnitEnumValueMap,
    ),
    r'projectionArea': PropertySchema(
      id: 5,
      name: r'projectionArea',
      type: IsarType.double,
    ),
    r'width': PropertySchema(
      id: 6,
      name: r'width',
      type: IsarType.double,
    ),
    r'widthDisplayUnit': PropertySchema(
      id: 7,
      name: r'widthDisplayUnit',
      type: IsarType.int,
      enumMap: _DimensionswidthDisplayUnitEnumValueMap,
    )
  },
  estimateSize: _dimensionsEstimateSize,
  serialize: _dimensionsSerialize,
  deserialize: _dimensionsDeserialize,
  deserializeProp: _dimensionsDeserializeProp,
);

int _dimensionsEstimateSize(
  Dimensions object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _dimensionsSerialize(
  Dimensions object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeInt(offsets[0], object.areaDisplayUnit?.multiplier);
  writer.writeDouble(offsets[1], object.height);
  writer.writeInt(offsets[2], object.heightDisplayUnit?.multiplier);
  writer.writeDouble(offsets[3], object.length);
  writer.writeInt(offsets[4], object.lengthDisplayUnit?.multiplier);
  writer.writeDouble(offsets[5], object.projectionArea);
  writer.writeDouble(offsets[6], object.width);
  writer.writeInt(offsets[7], object.widthDisplayUnit?.multiplier);
}

Dimensions _dimensionsDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Dimensions(
    areaDisplayUnit: _DimensionsareaDisplayUnitValueEnumMap[
        reader.readIntOrNull(offsets[0])],
    height: reader.readDoubleOrNull(offsets[1]),
    heightDisplayUnit: _DimensionsheightDisplayUnitValueEnumMap[
        reader.readIntOrNull(offsets[2])],
    length: reader.readDoubleOrNull(offsets[3]),
    lengthDisplayUnit: _DimensionslengthDisplayUnitValueEnumMap[
        reader.readIntOrNull(offsets[4])],
    projectionArea: reader.readDoubleOrNull(offsets[5]),
    width: reader.readDoubleOrNull(offsets[6]),
    widthDisplayUnit: _DimensionswidthDisplayUnitValueEnumMap[
        reader.readIntOrNull(offsets[7])],
  );
  return object;
}

P _dimensionsDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (_DimensionsareaDisplayUnitValueEnumMap[
          reader.readIntOrNull(offset)]) as P;
    case 1:
      return (reader.readDoubleOrNull(offset)) as P;
    case 2:
      return (_DimensionsheightDisplayUnitValueEnumMap[
          reader.readIntOrNull(offset)]) as P;
    case 3:
      return (reader.readDoubleOrNull(offset)) as P;
    case 4:
      return (_DimensionslengthDisplayUnitValueEnumMap[
          reader.readIntOrNull(offset)]) as P;
    case 5:
      return (reader.readDoubleOrNull(offset)) as P;
    case 6:
      return (reader.readDoubleOrNull(offset)) as P;
    case 7:
      return (_DimensionswidthDisplayUnitValueEnumMap[
          reader.readIntOrNull(offset)]) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _DimensionsareaDisplayUnitEnumValueMap = {
  'millimeter': 1,
  'centimeter': 10,
  'decimeter': 100,
  'meter': 1000,
};
const _DimensionsareaDisplayUnitValueEnumMap = {
  1: SizeUnit.millimeter,
  10: SizeUnit.centimeter,
  100: SizeUnit.decimeter,
  1000: SizeUnit.meter,
};
const _DimensionsheightDisplayUnitEnumValueMap = {
  'millimeter': 1,
  'centimeter': 10,
  'decimeter': 100,
  'meter': 1000,
};
const _DimensionsheightDisplayUnitValueEnumMap = {
  1: SizeUnit.millimeter,
  10: SizeUnit.centimeter,
  100: SizeUnit.decimeter,
  1000: SizeUnit.meter,
};
const _DimensionslengthDisplayUnitEnumValueMap = {
  'millimeter': 1,
  'centimeter': 10,
  'decimeter': 100,
  'meter': 1000,
};
const _DimensionslengthDisplayUnitValueEnumMap = {
  1: SizeUnit.millimeter,
  10: SizeUnit.centimeter,
  100: SizeUnit.decimeter,
  1000: SizeUnit.meter,
};
const _DimensionswidthDisplayUnitEnumValueMap = {
  'millimeter': 1,
  'centimeter': 10,
  'decimeter': 100,
  'meter': 1000,
};
const _DimensionswidthDisplayUnitValueEnumMap = {
  1: SizeUnit.millimeter,
  10: SizeUnit.centimeter,
  100: SizeUnit.decimeter,
  1000: SizeUnit.meter,
};

extension DimensionsQueryFilter
    on QueryBuilder<Dimensions, Dimensions, QFilterCondition> {
  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      areaDisplayUnitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'areaDisplayUnit',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      areaDisplayUnitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'areaDisplayUnit',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      areaDisplayUnitEqualTo(SizeUnit? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'areaDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      areaDisplayUnitGreaterThan(
    SizeUnit? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'areaDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      areaDisplayUnitLessThan(
    SizeUnit? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'areaDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      areaDisplayUnitBetween(
    SizeUnit? lower,
    SizeUnit? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'areaDisplayUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> heightIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'height',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      heightIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'height',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> heightEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> heightGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> heightLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'height',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> heightBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'height',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      heightDisplayUnitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'heightDisplayUnit',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      heightDisplayUnitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'heightDisplayUnit',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      heightDisplayUnitEqualTo(SizeUnit? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heightDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      heightDisplayUnitGreaterThan(
    SizeUnit? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heightDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      heightDisplayUnitLessThan(
    SizeUnit? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heightDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      heightDisplayUnitBetween(
    SizeUnit? lower,
    SizeUnit? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heightDisplayUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> lengthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'length',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      lengthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'length',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> lengthEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'length',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> lengthGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'length',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> lengthLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'length',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> lengthBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'length',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      lengthDisplayUnitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lengthDisplayUnit',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      lengthDisplayUnitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lengthDisplayUnit',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      lengthDisplayUnitEqualTo(SizeUnit? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lengthDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      lengthDisplayUnitGreaterThan(
    SizeUnit? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lengthDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      lengthDisplayUnitLessThan(
    SizeUnit? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lengthDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      lengthDisplayUnitBetween(
    SizeUnit? lower,
    SizeUnit? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lengthDisplayUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      projectionAreaIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'projectionArea',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      projectionAreaIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'projectionArea',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      projectionAreaEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'projectionArea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      projectionAreaGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'projectionArea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      projectionAreaLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'projectionArea',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      projectionAreaBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'projectionArea',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> widthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'width',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> widthIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'width',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> widthEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'width',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> widthGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'width',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> widthLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'width',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition> widthBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'width',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      widthDisplayUnitIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'widthDisplayUnit',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      widthDisplayUnitIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'widthDisplayUnit',
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      widthDisplayUnitEqualTo(SizeUnit? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'widthDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      widthDisplayUnitGreaterThan(
    SizeUnit? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'widthDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      widthDisplayUnitLessThan(
    SizeUnit? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'widthDisplayUnit',
        value: value,
      ));
    });
  }

  QueryBuilder<Dimensions, Dimensions, QAfterFilterCondition>
      widthDisplayUnitBetween(
    SizeUnit? lower,
    SizeUnit? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'widthDisplayUnit',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension DimensionsQueryObject
    on QueryBuilder<Dimensions, Dimensions, QFilterCondition> {}
