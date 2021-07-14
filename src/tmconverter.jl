
"""Construct a TopicModelsVB.Corpus from a
CitableTextCorpus.

$(SIGNATURES)

To build a TopicModelsVB.Corpus, we need data in local files. 
At a minimum, we need a lexicon file and the DT matrix.
"""
function tmcorpus(c::CitableTextCorpus)
    tacorp = tacorpus(c)
	update_inverse_index!(tacorp)
	update_lexicon!(tacorp)
	lex = 	lexicon(tacorp)
    lexlines = []
    sparsedtm = DocumentTermMatrix(tacorp)
	for k in keys(lex)
		push!(lexlines, string(termcolumn(k, sparsedtm),"\t", k))
	end
	lextsv = join(lexlines,"\n") * "\n"
    lexfile = tempname()
	open(lexfile,"w") do io
		write(io,lextsv)	
	end
	@info "Lexicon file: $lexfile"

	m = dtmatrix(c)
	tmdata = indexnz(m)    	
	tmdocfile = tempname()
	datastrings = map(rowv -> join(rowv,","), tmdata)
	open(tmdocfile,"w") do io
		write(io, join(datastrings,"\n"))
	end
	@info "Document-matrix file $tmdocfile"
	
	tmcorp = readcorp(docfile=tmdocfile, vocabfile=lexfile)
	TopicModelsVB.fixcorp!(tmcorp, trim=true)
	tmcorp
end

""" Find column index for given term.

$(SIGNATURES)
"""
function termcolumn(trm,sparsem) 
	findfirst(t -> t == trm, sparsem.terms)
end


"""Get indices of non-zero values for each row in document-term matrix.

$(SIGNATURES)
"""
function indexnz(mtrx)
	allrows = []
    #rcount = 0
	for r in eachrow(mtrx)
        #rcount = rcount + 1
		rowindices = []
		for c = 1:length(r)
			if r[c] != 0
                #println(rcount, "/", c,": ", r[c])
				push!(rowindices,c)
            else
                #println("0 val")
			end
		end
		#push!(allrows, join(rowindices,","))
		push!(allrows, rowindices)
	end
	allrows
end