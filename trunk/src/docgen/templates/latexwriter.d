/**
 * Author: Jari-Matti Mäkelä
 * License: GPL3
 */
module docgen.templates.latexwriter;

import docgen.templates.writer;
import tango.io.FileConduit : FileConduit;
import tango.io.Print: Print;
import tango.text.convert.Layout : Layout;

/**
 * Writes a LaTeX document skeleton.
 */
class LaTeXWriter : AbstractWriter!(TemplateWriterFactory, 1), TemplateWriter {
  this(TemplateWriterFactory factory, OutputStream[] outputs) {
    super(factory, outputs);
  }

  void generateTemplate() {
    auto output = new Print!(char)(new Layout!(char), outputs[0]);
    
    output(`
    \documentclass[` ~ factory.options.templates.paperSize ~ `]{book}
    \usepackage{a4wide}
    \usepackage{makeidx}
    \usepackage{fancyhdr}
    \usepackage{graphicx}
    \usepackage{multicol}
    \usepackage{float}
    \usepackage{textcomp}
    \usepackage{alltt}
    \usepackage[utf8]{inputenc}
    \usepackage{listings}
    \lstnewenvironment{dcode}
    { \lstset{language=d} }
    {}
    \lstset{` ~
      (factory.options.listings.literateStyle ? ` 
      literate=
               {<=}{{$\leq$}}1
               {>=}{{$\geq$}}1
               {!=}{{$\neq$}}1
               {...}{{$\dots$}}1
               {~}{{$\sim$}}1,` : ``) ~ `
      stringstyle=\ttfamily,
      inputencoding=utf8,
      extendedchars=false,
      columns=fixed,
      basicstyle=\small
    }
    \makeindex
    \setcounter{tocdepth}{1}
    \newcommand{\clearemptydoublepage}{\newpage{\pagestyle{empty}\cleardoublepage}}
    \def\thechapter{\Roman{chapter}}
    % \renewcommand{\footrulewidth}{0.4pt}

    \begin{document}

    \begin{titlepage}
    \vspace*{7cm}
    \begin{center}
    {\Large ` ~ factory.options.templates.title ~ ` Reference Manual\\[1ex]\large ` ~
        factory.options.templates.versionString ~ ` }\\
    \vspace*{1cm}
    {\large Generated by ` ~ docgen_version ~ `}\\
    \vspace*{0.5cm}
    {\small ` ~ timeNow() ~ `}\\
    \end{center}
    \end{titlepage}

    \clearemptydoublepage

    \tableofcontents
    \thispagestyle{empty}

    \clearemptydoublepage

    \setcounter{page}{1}
    \chapter{Module documentation}
    \input{modules}

    \chapter{File listings}
    \input{files}

    \chapter{Dependency diagram}
    \input{dependencies}

    \printindex

    \end{document}
    `);
  }
}