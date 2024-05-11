WPRDFS := ${shell cat pathways.txt | sed 's: :\\ :g' | sed -e 's/\(.*\)/wp\/Human\/\1.ttl/' }

FRAMEWORKVERSION=release-6
JENAVERSION=4.8.0

all: rdf

install:
	@wget -O libs/GPML2RDF-3.0.0-SNAPSHOT.jar https://github.com/wikipathways/wikipathways-curation-template/releases/download/${FRAMEWORKVERSION}/GPML2RDF-3.0.0-SNAPSHOT.jar
	@wget -O libs/wikipathways.curator-1-SNAPSHOT.jar https://github.com/wikipathways/wikipathways-curation-template/releases/download/${FRAMEWORKVERSION}/wikipathways.curator-1-SNAPSHOT.jar
	@wget -O libs/slf4j-simple-1.7.32.jar https://search.maven.org/remotecontent?filepath=org/slf4j/slf4j-simple/1.7.32/slf4j-simple-1.7.32.jar
	@wget -O libs/jena-arq-${JENAVERSION}.jar https://repo1.maven.org/maven2/org/apache/jena/jena-arq/${JENAVERSION}/jena-arq-${JENAVERSION}.jar

pathways.txt:
	@find pathways -name "*gpml" | cut -d'/' -f2 | sort | cut -d'.' -f1 > pathways.txt

rdf: ${WPRDFS}
pmids: ${PMIDS}
gpml: ${GPMLS}
sbml: ${SBMLS}
svg: ${SVGS}
bioschemas: ${BS}

clean:
	@rm -f ${GPMLS}

distclean: clean
	@rm libs/*.jar

wp/Human/%.ttl: pathways/%.gpml src/java/main/org/wikipathways/curator/CreateRDF.class
	echo "Creating $@ WPRDF from $< ..."
	@mkdir -p wp/Human
	xpath -q -e "string(/Pathway/Attribute[@Key='reactome_id']/@Value)" "$<" | cut -d'_' -f2 | xargs java -cp src/java/main/.:libs/GPML2RDF-3.0.0-SNAPSHOT.jar:libs/derby-10.14.2.0.jar:libs/slf4j-simple-1.7.32.jar org.wikipathways.curator.CreateRDF "$<" "$@" V88

src/java/main/org/wikipathways/curator/CreateRDF.class: src/java/main/org/wikipathways/curator/CreateRDF.java
	@echo "Compiling $@ ..."
	@javac -cp libs/GPML2RDF-3.0.0-SNAPSHOT.jar src/java/main/org/wikipathways/curator/CreateRDF.java
