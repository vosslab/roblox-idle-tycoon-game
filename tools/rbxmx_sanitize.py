#!/usr/bin/env python3

import argparse
import base64
import re


ATTRIBUTES_PATTERN = re.compile(
	r'<string name="AttributesSerialize">(.*?)</string>',
	re.DOTALL
)
CONTENT_STRING_PATTERN = re.compile(
	r'<string name="([A-Za-z0-9_]+)">(.*?)</string>',
	re.DOTALL
)
INVALID_ENTITY_PATTERN = re.compile(r"&#(x[0-9A-Fa-f]+|[0-9]+);")
INVALID_CHAR_PATTERN = re.compile(r"[\x00-\x08\x0B\x0C\x0E-\x1F]")

CONTENT_NAMES = {
	"AnimationId",
	"DisabledImage",
	"HoverImage",
	"Image",
	"ImageId",
	"MeshId",
	"PressedImage",
	"SelectedImage",
	"SoundId",
	"Texture",
	"TextureID",
	"TextureId",
}
CONTENT_SUFFIXES = (
	"Image",
	"ImageId",
	"Texture",
	"TextureId",
	"MeshId",
	"SoundId",
	"AnimationId",
	"Video",
	"VideoId",
)

HTML_ENTITIES = {
	"amp": ord("&"),
	"lt": ord("<"),
	"gt": ord(">"),
	"quot": ord("\""),
	"apos": ord("'"),
}


#============================================
def decode_entities(text: str) -> bytes:
	"""
	Decode XML numeric entities and basic HTML entities into raw bytes.
	"""
	out = bytearray()
	i = 0
	while i < len(text):
		if text[i] == "&":
			if text.startswith("&#", i):
				end = text.find(";", i)
				if end == -1:
					break
				token = text[i + 2:end]
				code = int(token[1:], 16) if token.lower().startswith("x") else int(token, 10)
				out.append(code & 0xFF)
				i = end + 1
				continue
			end = text.find(";", i)
			if end != -1:
				token = text[i + 1:end]
				if token in HTML_ENTITIES:
					out.append(HTML_ENTITIES[token])
					i = end + 1
					continue
		out.append(ord(text[i]))
		i += 1
	return bytes(out)


#============================================
def rewrite_attributes_serialize(text: str) -> tuple:
	"""
	Replace AttributesSerialize strings with BinaryString base64 content.
	"""
	def replacer(match: re.Match) -> str:
		raw = match.group(1)
		decoded = decode_entities(raw)
		encoded = base64.b64encode(decoded).decode("ascii")
		return f'<BinaryString name="AttributesSerialize">{encoded}</BinaryString>'

	new_text, count = ATTRIBUTES_PATTERN.subn(replacer, text)
	return new_text, count


#============================================
def rewrite_content_strings(text: str) -> tuple:
	"""
	Convert ContentId properties from string tags to Content tags.
	"""
	def is_content_name(name: str, body: str) -> bool:
		if name in CONTENT_NAMES:
			return True
		for suffix in CONTENT_SUFFIXES:
			if name.endswith(suffix):
				return True
		return False

	def replacer(match: re.Match) -> str:
		name = match.group(1)
		body = match.group(2)
		if is_content_name(name, body):
			body_stripped = body.strip()
			if body_stripped == "":
				return ""
			return f'<Content name="{name}"><url>{body_stripped}</url></Content>'
		return match.group(0)

	new_text, count = CONTENT_STRING_PATTERN.subn(replacer, text)
	return new_text, count


#============================================
def sanitize_invalid_entities(text: str) -> tuple:
	"""
	Remove invalid control-character entities from XML.
	"""
	def replacer(match: re.Match) -> str:
		token = match.group(1)
		code = int(token[1:], 16) if token.lower().startswith("x") else int(token, 10)
		if code in (9, 10, 13):
			return match.group(0)
		if 0 <= code < 32:
			return ""
		return match.group(0)

	new_text, count = INVALID_ENTITY_PATTERN.subn(replacer, text)
	return new_text, count


#============================================
def sanitize_raw_control_chars(text: str) -> tuple:
	"""
	Strip raw control characters that are invalid in XML 1.0.
	"""
	new_text, count = INVALID_CHAR_PATTERN.subn("", text)
	return new_text, count


#============================================
def parse_args() -> argparse.Namespace:
	"""
	Parse command-line arguments.
	"""
	parser = argparse.ArgumentParser(
		description="Sanitize rbxmx XML for AttributesSerialize and ContentId fields."
	)
	parser.add_argument(
		"-i", "--input", dest="input_path", required=True, help="Input .rbxmx path"
	)
	parser.add_argument(
		"-o", "--output", dest="output_path", required=True, help="Output .rbxmx path"
	)
	return parser.parse_args()


#============================================
def main():
	"""
	Entry point for XML sanitizing.
	"""
	args = parse_args()
	with open(args.input_path, "r", encoding="utf-8") as handle:
		text = handle.read()

	text, attr_count = rewrite_attributes_serialize(text)
	text, invalid_count = sanitize_invalid_entities(text)
	text, raw_count = sanitize_raw_control_chars(text)
	text, content_count = rewrite_content_strings(text)

	with open(args.output_path, "w", encoding="utf-8") as handle:
		handle.write(text)

	print(f"Rewrote {attr_count} AttributesSerialize entries")
	print(f"Removed {invalid_count} invalid XML entities")
	print(f"Removed {raw_count} invalid XML characters")
	print(f"Converted {content_count} ContentId string entries")


#============================================
if __name__ == "__main__":
	main()
