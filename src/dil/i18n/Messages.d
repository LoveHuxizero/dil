/// Author: Aziz Köksal
/// License: GPL3
/// $(Maturity average)
module dil.i18n.Messages;

// How to add a new message:
// 1. Insert short but descriptive identifier in MID.
// 2. Open all data/lang_*.d files.
// 3. Insert the new message at the same position.
// 4. Insert null when the translation is not available yet.

/// Enumeration of indices into the table of compiler messages.
enum MID
{
  // Lexer messages:
  IllegalCharacter,
//   InvalidUnicodeCharacter,
  InvalidUTF8Sequence,
  // ''
  UnterminatedCharacterLiteral,
  EmptyCharacterLiteral,
  // #line
  ExpectedIdentifierSTLine,
  ExpectedIntegerAfterSTLine,
//   ExpectedFilespec,
  UnterminatedFilespec,
  UnterminatedSpecialToken,
  // ""
  UnterminatedString,
  // x""
  NonHexCharInHexString,
  OddNumberOfDigitsInHexString,
  UnterminatedHexString,
  // /* */ /+ +/
  UnterminatedBlockComment,
  UnterminatedNestedComment,
  // `` r""
  UnterminatedRawString,
  UnterminatedBackQuoteString,
  // \x \u \U
  UndefinedEscapeSequence,
  InvalidUnicodeEscapeSequence,
  InsufficientHexDigits,
  // \&[a-zA-Z][a-zA-Z0-9]+;
  UndefinedHTMLEntity,
  UnterminatedHTMLEntity,
  InvalidBeginHTMLEntity,
  // integer overflows
  OverflowDecimalSign,
  OverflowDecimalNumber,
  OverflowHexNumber,
  OverflowBinaryNumber,
  OverflowOctalNumber,
  OverflowFloatNumber,
  OctalNumberHasDecimals,
  OctalNumbersDeprecated,
  NoDigitsInHexNumber,
  NoDigitsInBinNumber,
  HexFloatExponentRequired,
  HexFloatExpMustStartWithDigit,
  FloatExpMustStartWithDigit,
  CantReadFile,
  InexistantFile,
  InvalidOctalEscapeSequence,
  InvalidModuleName,
  DelimiterIsWhitespace,
  DelimiterIsMissing,
  NoNewlineAfterIdDelimiter,
  UnterminatedDelimitedString,
  ExpectedDblQuoteAfterDelim,
  UnterminatedTokenString,

  // Parser messages:
  ExpectedButFound,
  RedundantStorageClass,
  TemplateTupleParameter,
  InContract,
  OutContract,
  MissingLinkageType,
  UnrecognizedLinkageType,
  ExpectedBaseClasses,
  BaseClassInForwardDeclaration,
  InvalidUTF8SequenceInString,
  ModuleDeclarationNotFirst,
  StringPostfixMismatch,
  UnexpectedIdentInType,
  ExpectedIdAfterTypeDot,
  ExpectedModuleIdentifier,
  IllegalDeclaration,
  ExpectedModuleType,
  ExpectedFunctionName,
  ExpectedVariableName,
  ExpectedFunctionBody,
  RedundantLinkageType,
  RedundantProtection,
  ExpectedPragmaIdentifier,
  ExpectedAliasModuleName,
  ExpectedAliasImportName,
  ExpectedImportName,
  ExpectedEnumMember,
  ExpectedEnumBody,
  ExpectedClassName,
  ExpectedClassBody,
  ExpectedInterfaceName,
  ExpectedInterfaceBody,
  ExpectedStructBody,
  ExpectedUnionBody,
  ExpectedUnittestBody,
  ExpectedTemplateName,
  ExpectedAnIdentifier,
  IllegalStatement,
  ExpectedNonEmptyDeclaration,
  ExpectedNonEmptyStatement,
  ExpectedScopeIdentifier,
  InvalidScopeIdentifier,
  ExpectedLinkageIdentifier,
  ExpectedAttributeId,
  UnrecognizedAttribute,
  ExpectedIntegerAfterAlign,
  IllegalAsmStatement,
  IllegalAsmBinaryOp,
  ExpectedDeclaratorIdentifier,
  ExpectedTemplateParameters,
  ExpectedTypeOrExpression,
  ExpectedAliasTemplateParam,
  ExpectedNameForThisTempParam,
  ExpectedIdentOrInt,
  MissingCatchOrFinally,
  ExpectedClosing,
  AliasHasInitializer,
  AliasExpectsVariable,
  TypedefExpectsVariable,
  CaseRangeStartExpression,
  ExpectedParamDefValue,
  IllegalVariadicParam,
  ParamsAfterVariadic,
  CannotChainComparisonOps,

  // Semantic analysis:
  CouldntLoadModule,
  ConflictingModuleFiles,
  ConflictingModuleAndPackage,
  ConflictingPackageAndModule,
  ModuleNotInPackage,
  UndefinedIdentifier,
  DeclConflictsWithDecl,
  VariableConflictsWithDecl,
  InterfaceCantHaveVariables,
  MixinArgumentMustBeString,
  DebugSpecModuleLevel,
  VersionSpecModuleLevel,
  InvalidUTF16Sequence,
  MissingLowSurrogate,
  MissingHighSurrogate,
  InvalidTemplateArgument,

  // Converter:
  InvalidUTF16Character,
  InvalidUTF32Character,
  UTF16FileMustBeDivisibleBy2,
  UTF32FileMustBeDivisibleBy4,

  // DDoc messages:
  UndefinedDDocMacro,
  UnterminatedDDocMacro,
  UndocumentedSymbol,
  EmptyDDocComment,
  MissingParamsSection,
  UndocumentedParam,

  // Help messages:
  UnknownCommand,
  UsageError,
  MissingOptionArgument,
  HelpMain,
  HelpCompile,
  HelpPytree,
  HelpDdoc,
  HelpHighlight,
  HelpImportGraph,
  HelpTokenize,
  HelpDlexed,
  HelpSerialize,
  HelpStatistics,
  HelpTranslate,
  HelpSettings,
  HelpHelp,
}
