class BankAccountIconModel {
  final String id;
  final String name;
  final String image;
  final String type;

  BankAccountIconModel({
    required this.id,
    required this.name,
    required this.image,
    required this.type,
  });

  // Converter de JSON (do Supabase) para o modelo
  factory BankAccountIconModel.fromJson(Map<String, dynamic> json) {
    return BankAccountIconModel(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      type: json['type'] as String,
    );
  }

  // Converter do modelo para JSON
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'image': image, 'type': type};
  }

  // Verificar se é um ícone genérico
  bool get isGeneric => type == 'generic';

  // Verificar se é um ícone de instituição bancária
  bool get isBankingInstitution => type == 'banking institution';

  @override
  String toString() {
    return 'BankAccountIconModel(id: $id, name: $name, image: $image, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BankAccountIconModel &&
        other.id == id &&
        other.name == name &&
        other.image == image &&
        other.type == type;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ image.hashCode ^ type.hashCode;
  }
}

// Classe para resposta da API com paginação
class BankAccountIconsResponse {
  final bool status;
  final String message;
  final List<BankAccountIconModel> data;
  final IconPagination? pagination;

  BankAccountIconsResponse({
    required this.status,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory BankAccountIconsResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>;
    final icons = dataList
        .map(
          (item) => BankAccountIconModel.fromJson(item as Map<String, dynamic>),
        )
        .toList();

    return BankAccountIconsResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: icons,
      pagination: json['pagination'] != null
          ? IconPagination.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

// Classe para informações de paginação
class IconPagination {
  final int totalItems;
  final int totalPages;
  final int currentPage;

  IconPagination({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
  });

  factory IconPagination.fromJson(Map<String, dynamic> json) {
    return IconPagination(
      totalItems: json['total_items'] as int,
      totalPages: json['total_pages'] as int,
      currentPage: json['current_page'] as int,
    );
  }

  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
}
