#!/bin/bash 
#absolute path point to NNSegmentation directory
workspace=`pwd`
tooldir=$workspace/../../NNSegmentation-partial-version-20180428
corpus=ctb
#uni_emb=./embeddings/char.vec
#bi_emb=./embeddings/bichar.vec
#tri_emb=./embeddings/trichar.vec
#glyph_emb=./embeddings/glyphchar.vec











outputdir=$corpus.sample

mkdir -p $outputdir
rm $outputdir/* -rf

function extract
{
    #extracting your features here
    echo "[self implementation]"
}

function runSparse
{
    cmd=$1
    echo $cmd
    mkdir $workspace/$outputdir/$cmd -p
    ln -s $workspace/$corpus/$corpus.train.combine.feats $workspace/$outputdir/$cmd/$corpus.train.feats 
    ln -s $workspace/$corpus/$corpus.sample.dev.feats $workspace/$outputdir/$cmd/$corpus.dev.feats 
    ln -s $workspace/$corpus/$corpus.test.feats $workspace/$outputdir/$cmd/$corpus.test.feats 
    cp $tooldir/$cmd $workspace/$outputdir/$cmd/
    train_file=$workspace/$outputdir/$cmd/$corpus.train.feats
    dev_file=$workspace/$outputdir/$cmd/$corpus.dev.feats
    test_file=$workspace/$outputdir/$cmd/$corpus.test.feats
    nohup $workspace/$outputdir/$cmd/$cmd -l -train $train_file -dev $dev_file  -test $test_file -option ./options/option.sparse -model $workspace/$outputdir/$cmd/$cmd.model >$workspace/$outputdir/$cmd.log 2>&1 &
}
function runLSTM
{
    cmd=$1
    option=$2
    echo $cmd, $option
    echo $workspace/$outputdir/$cmd.log  
    echo $tooldir/$cmd 
    echo $workspace/$outputdir/$cmd/$cmd.model



    mkdir $workspace/$outputdir/$cmd -p
    ln -s $workspace/$corpus/$corpus.train.bichar.test $workspace/$outputdir/$cmd/$corpus.train.feats 
    ln -s $workspace/$corpus/$corpus.dev.bichar.test $workspace/$outputdir/$cmd/$corpus.dev.feats 
    ln -s $workspace/$corpus/$corpus.test.bichar.test $workspace/$outputdir/$cmd/$corpus.test.feats 
    cp $tooldir/$cmd $workspace/$outputdir/$cmd/
    train_file=$workspace/$outputdir/$cmd/$corpus.train.feats
    dev_file=$workspace/$outputdir/$cmd/$corpus.dev.feats
    test_file=$workspace/$outputdir/$cmd/$corpus.test.feats
    #character bigram embedding and character trigram embedding should use a comma to separate 
    nohup $workspace/$outputdir/$cmd/$cmd -l -train $train_file \
        -dev $dev_file \
        -test $test_file \
        -option $option \
        -model $workspace/$outputdir/$cmd/$cmd.model \
    >$workspace/$outputdir/$cmd.log 2>&1 &
}

echo "Step 1: Extracting Features..."
extract $corpus 
echo "Step 2: Running SparseCRFMMLabeler..."
#runSparse SparseCRFMMLabeler
echo "Step 3: Running LSTMCRFMLLabeler..."
cmds="LSTMCRFMLLabeler"
runLSTM LSTMCRFMLLabeler ./options/option.lstm
#runLSTM SparseLSTMCRFMMLabeler ./options/option.sparse+lstm
echo "Successfully run!"
