class Repository {
  final int id;
  final String name;
  final String owner;
  final int stars;

  Repository({required this.id, required this.name, required this.owner, required this.stars});

  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'],
      name: json['name'],
      owner: json['owner']['login'],
      stars: json['stargazers_count'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'owner': owner,
      'stars': stars,
    };
  }
}