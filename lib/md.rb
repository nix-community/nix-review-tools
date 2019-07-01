module MD
  def self.join(*args)
    args.join("\n")
  end

  def self.title(text)
    [
      text,
      text.gsub(/./, "="),
      "",
    ].join("\n")
  end

  def self.subtitle(text)
    [
      text,
      text.gsub(/./, "-"),
      "",
    ].join("\n")
  end

  def self.paragraph(text)
    [
      text,
      "",
    ].join("\n")
  end

  def self.header(level, text)
    [
      level * "#",
      text,
      "\n",
    ].join()
  end

  def self.code(value, language: "")
    # TODO: detect "```" and add as many ` as required  to be unique.
    [
      "```#{language}",
      value,
      "```",
    ].join("\n")
  end

  def self.italics(text)
    ["*", text, "*"].join()
  end
end
