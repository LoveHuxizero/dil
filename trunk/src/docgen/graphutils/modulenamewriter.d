/**
 * Author: Aziz Köksal & Jari-Matti Mäkelä
 * License: GPL3
 */
module docgen.graphutils.modulenamewriter;
import docgen.graphutils.writer;

import tango.io.FileConduit : FileConduit;
import tango.io.Print: Print;
import tango.text.convert.Layout : Layout;

/**
 * TODO: add support for html/xml/latex?
 */
class ModuleNameWriter : AbstractWriter!(GraphWriterFactory, 1), GraphWriter {
  this(GraphWriterFactory factory, OutputStream[] outputs) {
    super(factory, outputs);
  }

  void generateGraph(Vertex[] vertices, Edge[] edges) {
    auto output = new Print!(char)(new Layout!(char), outputs[0]);

    void doList(Vertex[] v, uint level, char[] indent = "") {
      if (!level) return;

      foreach (vertex; v) {
        output(indent)(vertex.name).newline;
        if (vertex.outgoing.length)
          doList(vertex.outgoing, level-1, indent ~ "  ");
      }
    }

    doList(vertices, factory.options.graph.depth);
  }
}