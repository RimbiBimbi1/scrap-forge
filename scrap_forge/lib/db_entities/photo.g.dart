// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPhotoCollection on Isar {
  IsarCollection<Photo> get photos => this.collection();
}

const PhotoSchema = CollectionSchema(
  name: r'Photo',
  id: 7605685642742149252,
  properties: {
    r'imgData': PropertySchema(
      id: 0,
      name: r'imgData',
      type: IsarType.string,
    )
  },
  estimateSize: _photoEstimateSize,
  serialize: _photoSerialize,
  deserialize: _photoDeserialize,
  deserializeProp: _photoDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'product': LinkSchema(
      id: -994629758425837141,
      name: r'product',
      target: r'Product',
      single: true,
      linkName: r'photos',
    )
  },
  embeddedSchemas: {},
  getId: _photoGetId,
  getLinks: _photoGetLinks,
  attach: _photoAttach,
  version: '3.1.0+1',
);

int _photoEstimateSize(
  Photo object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.imgData;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _photoSerialize(
  Photo object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.imgData);
}

Photo _photoDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Photo();
  object.id = id;
  object.imgData = reader.readStringOrNull(offsets[0]);
  return object;
}

P _photoDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _photoGetId(Photo object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _photoGetLinks(Photo object) {
  return [object.product];
}

void _photoAttach(IsarCollection<dynamic> col, Id id, Photo object) {
  object.id = id;
  object.product.attach(col, col.isar.collection<Product>(), r'product', id);
}

extension PhotoQueryWhereSort on QueryBuilder<Photo, Photo, QWhere> {
  QueryBuilder<Photo, Photo, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PhotoQueryWhere on QueryBuilder<Photo, Photo, QWhereClause> {
  QueryBuilder<Photo, Photo, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Photo, Photo, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Photo, Photo, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Photo, Photo, QAfterWhereClause> idBetween(
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

extension PhotoQueryFilter on QueryBuilder<Photo, Photo, QFilterCondition> {
  QueryBuilder<Photo, Photo, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Photo, Photo, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Photo, Photo, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'imgData',
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'imgData',
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imgData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'imgData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'imgData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'imgData',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'imgData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'imgData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'imgData',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'imgData',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'imgData',
        value: '',
      ));
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> imgDataIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'imgData',
        value: '',
      ));
    });
  }
}

extension PhotoQueryObject on QueryBuilder<Photo, Photo, QFilterCondition> {}

extension PhotoQueryLinks on QueryBuilder<Photo, Photo, QFilterCondition> {
  QueryBuilder<Photo, Photo, QAfterFilterCondition> product(
      FilterQuery<Product> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'product');
    });
  }

  QueryBuilder<Photo, Photo, QAfterFilterCondition> productIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'product', 0, true, 0, true);
    });
  }
}

extension PhotoQuerySortBy on QueryBuilder<Photo, Photo, QSortBy> {
  QueryBuilder<Photo, Photo, QAfterSortBy> sortByImgData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imgData', Sort.asc);
    });
  }

  QueryBuilder<Photo, Photo, QAfterSortBy> sortByImgDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imgData', Sort.desc);
    });
  }
}

extension PhotoQuerySortThenBy on QueryBuilder<Photo, Photo, QSortThenBy> {
  QueryBuilder<Photo, Photo, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Photo, Photo, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Photo, Photo, QAfterSortBy> thenByImgData() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imgData', Sort.asc);
    });
  }

  QueryBuilder<Photo, Photo, QAfterSortBy> thenByImgDataDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'imgData', Sort.desc);
    });
  }
}

extension PhotoQueryWhereDistinct on QueryBuilder<Photo, Photo, QDistinct> {
  QueryBuilder<Photo, Photo, QDistinct> distinctByImgData(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'imgData', caseSensitive: caseSensitive);
    });
  }
}

extension PhotoQueryProperty on QueryBuilder<Photo, Photo, QQueryProperty> {
  QueryBuilder<Photo, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Photo, String?, QQueryOperations> imgDataProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'imgData');
    });
  }
}
