/// AI difficulty levels for computer opponents.
enum AiDifficulty {
  easy('Easy', 'Random moves'),
  medium('Medium', 'Smart trades & dogs'),
  hard('Hard', 'Optimal strategy');

  const AiDifficulty(this.label, this.description);

  final String label;
  final String description;
}
