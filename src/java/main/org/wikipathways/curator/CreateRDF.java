package org.wikipathways.curator;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Collections;

import org.bridgedb.DataSource;
import org.bridgedb.IDMapperException;
import org.bridgedb.IDMapperStack;
import org.bridgedb.bio.DataSourceTxt;
import org.pathvisio.core.model.ConverterException;
import org.pathvisio.core.model.Pathway;
import org.wikipathways.wp2rdf.io.PathwayReader;
import org.wikipathways.wp2rdf.GpmlConverter;
import org.wikipathways.wp2rdf.WPREST2RDF;

import org.apache.jena.rdf.model.Model;

public class CreateRDF {

    public static void main(String[] args) throws Exception {
        String gpmlFile = args[0];
        String outFile  = args[1];
        String wpid = "R-HSA-" + args[3];
        System.out.println("ID: " + wpid);
        String rev      = rev = args[2];
        if (rev.startsWith("r")) rev = rev.substring(1);

        DataSourceTxt.init();
        InputStream input = new FileInputStream(gpmlFile);
        Pathway pathway = PathwayReader.readPathway(input);
        input.close();

        IDMapperStack stack = WPREST2RDF.maps();
        Model model = GpmlConverter.convertWp(pathway, wpid, rev, stack, Collections.<String>emptyList());
        FileOutputStream output = new FileOutputStream(outFile);
        model.write(output, "TURTLE");
        output.flush();
        output.close();
    }

}
