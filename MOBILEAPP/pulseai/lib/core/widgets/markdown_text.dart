import 'package:flutter/material.dart';

/// Widget pour formatter le texte Markdown simple (*, **, -, •, etc.)
class MarkdownText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const MarkdownText({
    super.key,
    required this.text,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      _parseMarkdown(text, style ?? const TextStyle()),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextSpan _parseMarkdown(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final lines = text.split('\n');

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      
      // Gestion des listes avec - ou •
      if (line.trim().startsWith('- ') || line.trim().startsWith('• ')) {
        spans.add(TextSpan(text: '  • ', style: baseStyle));
        final content = line.trim().replaceFirst(RegExp(r'^[-•]\s+'), '');
        spans.addAll(_parseInlineMarkdown(content, baseStyle));
      } 
      // Gestion des titres avec **Titre:**
      else if (line.contains('**') && line.contains(':')) {
        spans.addAll(_parseInlineMarkdown(line, baseStyle));
      }
      // Ligne normale
      else {
        spans.addAll(_parseInlineMarkdown(line, baseStyle));
      }

      // Ajouter saut de ligne sauf pour la dernière ligne
      if (i < lines.length - 1) {
        spans.add(const TextSpan(text: '\n'));
      }
    }

    return TextSpan(children: spans, style: baseStyle);
  }

  List<InlineSpan> _parseInlineMarkdown(String text, TextStyle baseStyle) {
    final spans = <InlineSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*|`(.+?)`');
    int lastIndex = 0;

    for (final match in regex.allMatches(text)) {
      // Ajouter le texte avant le match
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: baseStyle,
        ));
      }

      // Traiter le match
      if (match.group(1) != null) {
        // **texte gras**
        spans.add(TextSpan(
          text: match.group(1),
          style: baseStyle.copyWith(fontWeight: FontWeight.bold),
        ));
      } else if (match.group(2) != null) {
        // *texte italique*
        spans.add(TextSpan(
          text: match.group(2),
          style: baseStyle.copyWith(fontStyle: FontStyle.italic),
        ));
      } else if (match.group(3) != null) {
        // `code`
        spans.add(TextSpan(
          text: match.group(3),
          style: baseStyle.copyWith(
            fontFamily: 'monospace',
            backgroundColor: Colors.grey.withOpacity(0.1),
          ),
        ));
      }

      lastIndex = match.end;
    }

    // Ajouter le reste du texte
    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: baseStyle,
      ));
    }

    return spans;
  }
}
