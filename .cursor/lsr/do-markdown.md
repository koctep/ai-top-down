# Markdown Guidelines

## General Principles

- **Readability**: source code of the document should be as readable as the rendered result.
- **Semantics**: use markup elements for their intended purpose (headers for structure, lists for enumerations).
- **Indentation**: use spaces (usually 2 or 4) for nesting. Do not use tabs.
- **Line Breaks**: an empty line separates paragraphs.

## Headers

- Use ATX style (`#` symbols).
- Always put a space after `#`.
- Observe hierarchy (h1 -> h2 -> h3). Do not skip levels (e.g., from h1 immediately to h3).
- Separate headers with an empty line above and below.

```markdown
# Level 1 Header

## Level 2 Header

### Level 3 Header
```

## Lists

- Use hyphen `-` or asterisk `*` for bulleted lists (be consistent).
- Use numbers with a dot `1.` for numbered lists.
- For nested lists use indentation of 2 or 4 spaces.

```markdown
- Item 1
- Item 2
  - Nested item
  - Nested item
- Item 3
```

## Code

- For code blocks use "fenced code blocks" (triple backticks) specifying the language.
- For inline code use single backticks.

````markdown
`inline code`

```python
def hello():
    print("world")
```
````

## Links and Images

- Use clear link text. Avoid "here" or "there".
- Always specify alt text for images.

```markdown
[Link text](https://example.com)

![Alt text for image](path/to/image.png)
```

## Text Formatting

- **Bold**: `**text**` or `__text__`.
- *Italic*: `*text*` or `_text_`.
- ~~Strikethrough~~: `~~text~~`.

## Tables

- Align columns for readability in source code (optional, but recommended).

```markdown
| Header 1    | Header 2    |
| ----------- | :---------: |
| Text        | Text        |
| Text        | Text        |
```

## Blockquotes

- Use `>` symbol before the line.

```markdown
> This is a quote.
>
> Second paragraph of the quote.
```
