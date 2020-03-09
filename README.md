# Labo Geavanceerde Computerarchitectuur
 
## Verslag

Volgende aspecten moeten zeker in het verslag aanwezig zijn:

- Kadering
- Probleemstelling: welke uitdagingen zijn er, wat wordt er onderzocht?
- Oplossing in de vorm van code en flowchart (eventueel een screenshot van de correcte werking)
- Besluit: wees kritisch over je resultaten

Probeer altijd duidelijk te maken waarom je iets gedaan hebt en interpreteer je resultaten op een kritische manier. Er worden 3 verslagen verwacht. Elk verslag wordt afgegeven het labo nadat de opdracht is afgewerkt. De 3 verslagen zijn:

CUDA array (add & invert)
CUDA image (greyscale & edge detector)
CUDA memory (global, shared memory, coalescing)
Stuur het labo als pdf op naar stijn.crul@kuleuven.be met als naamgeving volgende template:

labox_geavanceerde_voornaam1naam1_voornaam2naam2.pdf

Indien de afgesproken deadline niet gehaald wordt, zal de gegeven score halveren.

## Opgaves

1) Onderzoek de invloed van blocksize en memcopy. Wees kritisch en trek relevante conclusies uit de meetresultaten!
1) Schrijf een kernel die de volgorde van de elementen in een array omkeert
2) Schrijf een kernel die een grayscale maakt van een png-afbeelding
2) Schrijf een kernel die een edge detection uitvoert op een png-afbeelding

Laat de CPU dezelfde taak uitvoeren  
Voer volgende benchmarks uit voor alle opgaves!  
Meet de tijd om instructies uit te voeren op de CPU  
Meet de tijd om instructies uit te voeren op de GPU  
Met het verplaatsen van data tussen geheugens  
Zonder het verplaatsen van data tussen geheugens  
Doe dit voor verschillende blocksizes en loadsizes  


## Cuda performance metrics

Om correct benchmarks uit te voeren met CUDA:

https://devblogs.nvidia.com/parallelforall/how-implement-performance-metrics-cuda-cc/

## C bibliotheek voor IO afbeeldingen

https://github.com/lvandeve/lodepng

of

http://cimg.eu/reference/group__cimg__tutorial.html

## Verslag richtlijnen



- analyse probleem
- flowcharts + code
- waarom goed / niet goed?
- grafieken + tabellen, analyse van performantie
