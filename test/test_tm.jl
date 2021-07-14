@testset "Test creating topic modelling corpus" begin
    citable = CitableCorpus.fromfile(CitableTextCorpus,"data/tinyhyginus.cex")
    tmcorp = tmcorpus(citable)
    @test typeof(tmcorp) == TopicModelsVB.Corpus
    @test length(tmcorp.docs) == 6
end