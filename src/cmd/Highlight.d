/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity average)
module cmd.Highlight;

import cmd.Command;
import dil.Highlighter;
import dil.Diagnostics;
import dil.Compilation;
import SettingsLoader;
import Settings;
import common;

import std.file;

/// The highlight command.
class HighlightCommand : Command
{
  /// Options for the command.
  enum Option
  {
    None        = 0,
    Tokens      = 1,
    Syntax      = 1<<1,
    HTML        = 1<<2,
    XML         = 1<<3,
    PrintLines  = 1<<4
  }
  alias Options = Option;

  Options options; /// Command options.
  cstring filePathSrc; /// File path to the module to be highlighted.
  cstring filePathDest; /// Where to write the highlighted file.
  Diagnostics diag; /// Collects error messages.
  CompilationContext cc; /// The context.

  /// Adds o to the options.
  void add(Option o)
  {
    options |= o;
  }

  /// Executes the command.
  override void run()
  {
    add(HighlightCommand.Option.Tokens);
    if (!(options & (Option.XML | Option.HTML)))
      add(Option.HTML); // Default to HTML.

    auto mapFilePath = options & Option.HTML ? GlobalSettings.htmlMapFile
                                             : GlobalSettings.xmlMapFile;
    auto map = TagMapLoader(cc, diag).load(mapFilePath);
    auto tags = new TagMap(map);

    if (diag.hasInfo)
      return;

    auto hl = new Highlighter(tags, cc);

    bool printLines = (options & Option.PrintLines) != 0;
    bool printHTML = (options & Option.HTML) != 0;
    if (options & Option.Syntax)
      hl.highlightSyntax(filePathSrc, printHTML, printLines);
    else
      hl.highlightTokens(filePathSrc, printLines);

    auto text = hl.takeText();

    if (filePathDest.length)
      filePathDest.write(text);
    else
      Stdout(text);
  }
}
