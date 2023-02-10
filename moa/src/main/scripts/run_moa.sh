#trap "kill 0" EXIT
print_usage()
{
  echo "Usage: $0 <dataset_dir> <out_csv_dir> <djl_cache_dir> <local_maven_repo> <conda>"
  echo "e.g:   $0 ~/Desktop/datasets/NEW/unzipped/ ~/Desktop/results ~/Desktop/djl.ai/ ~/Desktop/m2_cache/ /Users/ng98/Desktop/condaJava"
  echo "e.g:   $0 /Scratch/ng98/datasets/NEW/unzipped/ /Scratch/ng98/JavaSetup1/resultsNN/Exp17_test/ /Scratch/ng98/JavaSetup1/djl.ai/ /Scratch/ng98/JavaSetup1/local_m2/ /Scratch/ng98/JavaSetup1/conda"
}

#Store the current Process ID, we don't want to kill the current executing process id
SCRIPT_PID=$$
echo "Script pid = $SCRIPT_PID"
#####################################################################################################
# config variables

GPUs_to_use='0'
CPUs_to_use='2,4,6,8,10'

#dataset=(spam_corpus WISDM_ar_v1.1_transformed elecNormNew nomao covtypeNorm kdd99 airlines RBF_f RBF_m LED_g LED_a AGR_a AGR_g)
dataset=(RBF_f RBF_m LED_g LED_a AGR_a AGR_g spam_corpus kdd99 airlines WISDM_ar_v1.1_transformed elecNormNew nomao covtypeNorm)
#dataset=(RBF_f RBF_m LED_g LED_a AGR_a AGR_g spam_corpus kdd99 airlines WISDM_ar_v1.1_transformed elecNormNew nomao covtypeNorm real-sim.libsvm.class_Nominal_sparse SVHN.scale.t.libsvm.sparse_class_Nominal sector.scale.libsvm.class_Nominal_sparse gisette_scale_class_Nominal epsilon_normalized.t_class_Nominal rcv1_train.binary_class_Nominal)
dataset=(RBF_f RBF_m LED_g LED_a AGR_a AGR_g spam_corpus kdd99 airlines WISDM_ar_v1.1_transformed elecNormNew nomao covtypeNorm real-sim.libsvm.class_Nominal_sparse SVHN.scale.t.libsvm.sparse_class_Nominal sector.scale.libsvm.class_Nominal_sparse gisette_scale_class_Nominal epsilon_normalized.t_class_Nominal)
dataset=(elecNormNew airlines covtypeNorm RBF_f RBF_m LED_g LED_a AGR_a AGR_g)
dataset=(spam_corpus kdd99 WISDM_ar_v1.1_transformed nomao SVHN.scale.t.libsvm.sparse_class_Nominal sector.scale.libsvm.class_Nominal_sparse gisette_scale_class_Nominal epsilon_normalized.t_class_Nominal)
dataset=(elecNormNew)
dataset=(elecNormNew airlines covtypeNorm RBF_f RBF_m LED_g LED_a AGR_a AGR_g spam_corpus kdd99 WISDM_ar_v1.1_transformed nomao SVHN.scale.t.libsvm.sparse_class_Nominal sector.scale.libsvm.class_Nominal_sparse gisette_scale_class_Nominal epsilon_normalized.t_class_Nominal)

use_datasets_without_drifts=0
#dataset=(AGR_a AGR_g elecNormNew airlines)
dataset=(AGR_a AGR_g elecNormNew)
#dataset=(AGR_a AGR_g)
#dataset=(LED _g LED_a)
#dataset=(RBF_f RBF_m)
#dataset=(AGR_a)
#dataset=(AGR_g)
#dataset=(LED_a)
#dataset=(LED_g)
#dataset=(RBF_f)
#dataset=(RBF_m)
#dataset=(RBF_Bf)
#dataset=(RBF_Bm)
#dataset=(airlines)
#dataset=(elecNormNew)
dataset=(covtypeNorm)
# use_datasets_without_drifts=1
#dataset=(RandomTreeGenerator RandomRBF LED elecNormNew nomao airlines covtypeNorm WISDM_ar_v1.1_transformed)
#dataset=(RandomRBF5 RandomTreeGenerator LED airlines)
#dataset=(RandomRBF5)
#dataset=(RandomTreeGenerator)
# dataset=(LED)

datasets_to_repeat=(WISDM_ar_v1.1_transformed elecNormNew nomao)
max_repeat=0

random_seed=121
random_seed=17
random_seed=9

# streams
use_full_generator_for_synthetic=0
LED_a_S="-s (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 1)   -d (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 3) -d (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 5)  -d (generators.LEDGeneratorDrift -d 7) -w 50 -p 250000 ) -w 50 -p 250000 ) -w 50 -p 250000 -r $random_seed )"
LED_g_S="-s (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 1)   -d (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 3) -d (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 5)  -d (generators.LEDGeneratorDrift -d 7) -w 50000 -p 250000 ) -w 50000 -p 250000 ) -w 50000 -p 250000 -r $random_seed )"
AGR_a_S="-s (ConceptDriftStream -s (generators.AgrawalGenerator -f 1) -d (ConceptDriftStream -s (generators.AgrawalGenerator -f 2) -d (ConceptDriftStream -s (generators.AgrawalGenerator )   -d (generators.AgrawalGenerator -f 4) -w 50 -p 250000 ) -w 50 -p 250000 ) -w 50 -p 250000 -r $random_seed )"
AGR_g_S="-s (ConceptDriftStream -s (generators.AgrawalGenerator -f 1) -d (ConceptDriftStream -s (generators.AgrawalGenerator -f 2) -d (ConceptDriftStream -s (generators.AgrawalGenerator )   -d (generators.AgrawalGenerator -f 4) -w 50000 -p 250000 ) -w 50000 -p 250000 ) -w 50000 -p 250000 -r $random_seed )"
RBF_m_S="-s (generators.RandomRBFGeneratorDrift -c 5 -s .0001 -r $random_seed -i $random_seed)"
RBF_f_S="-s (generators.RandomRBFGeneratorDrift -c 5 -s .001 -r $random_seed -i $random_seed)"
RBF_Bm_S="-s (generators.RandomRBFGeneratorDrift -c 2 -s .0001 -r $random_seed -i $random_seed)"
RBF_Bf_S="-s (generators.RandomRBFGeneratorDrift -c 2 -s .001 -r $random_seed -i $random_seed)"
RandomTreeGenerator_S="-s (generators.RandomTreeGenerator -r $random_seed -i $random_seed)"
RandomRBF_S="-s (generators.RandomRBFGenerator -r $random_seed -i $random_seed)"
RandomRBF_S="-s (generators.RandomRBFGenerator -r $random_seed -i $random_seed -c 3)"
RandomRBF3_S="-s (generators.RandomRBFGenerator -r $random_seed -i $random_seed -c 3)"
RandomRBF5_S="-s (generators.RandomRBFGenerator -r $random_seed -i $random_seed -c 5)"
RandomRBF6_S="-s (generators.RandomRBFGenerator -r $random_seed -i $random_seed -c 6)"
RandomRBF9_S="-s (generators.RandomRBFGenerator -r $random_seed -i $random_seed -c 9)"
LED_S="-s (generators.LEDGenerator -i $random_seed)"
#RandomTreeGenerator RandomRBF LED

use_scaled_generator_for_synthetic=1
LED_a_S_10="-s (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 1)   -d (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 3) -d (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 5)  -d (generators.LEDGeneratorDrift -d 7) -w 50 -p 25000 ) -w 50 -p 25000 ) -w 50 -p 25000 -r $random_seed )"
LED_g_S_10="-s (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 1)   -d (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 3) -d (ConceptDriftStream -s (generators.LEDGeneratorDrift -d 5)  -d (generators.LEDGeneratorDrift -d 7) -w 5000 -p 25000 ) -w 5000 -p 25000 ) -w 5000 -p 25000 -r $random_seed )"
AGR_a_S_10="-s (ConceptDriftStream -s (generators.AgrawalGenerator -f 1) -d (ConceptDriftStream -s (generators.AgrawalGenerator -f 2) -d (ConceptDriftStream -s (generators.AgrawalGenerator )   -d (generators.AgrawalGenerator -f 4) -w 50 -p 25000 ) -w 50 -p 25000 ) -w 50 -p 25000 -r $random_seed )"
AGR_g_S_10="-s (ConceptDriftStream -s (generators.AgrawalGenerator -f 1) -d (ConceptDriftStream -s (generators.AgrawalGenerator -f 2) -d (ConceptDriftStream -s (generators.AgrawalGenerator )   -d (generators.AgrawalGenerator -f 4) -w 5000 -p 25000 ) -w 5000 -p 25000 ) -w 5000 -p 25000 -r $random_seed )"
RBF_m_S_10="$RBF_m_S"
RBF_f_S_10="$RBF_f_S"
RBF_Bm_S_10="$RBF_Bm_S"
RBF_Bf_S_10="$RBF_Bf_S"
RandomTreeGenerator_S_10="$RandomTreeGenerator_S"
RandomRBF_S_10="$RandomRBF_S"
RandomRBF3_S_10="$RandomRBF3_S"
RandomRBF5_S_10="$RandomRBF5_S"
RandomRBF6_S_10="$RandomRBF6_S"
RandomRBF9_S_10="$RandomRBF9_S"
LED_S_10="$LED_S"

# times to re-run on failure
max_re_run_count=0

#####################################################################################################
# learners=('neuralNetworks.ReadVotes')

#####################################################################################################
# ADL Votes reader
# learners=('neuralNetworks.ADLVotesReader')

#####################################################################################################
# 10 MLPs setting
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 1' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 4' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 4 -M' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 8' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 8 -M' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 16' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 16 -M' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 32' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 32 -M' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 64' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P10 -B 64 -M')
#learners=('neuralNetworks.MultiMLP -d CPU -h -n -o 10 -O 10 -R -P P10 -B 1')

# 10/30 MLPs setting
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 4 -M' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 8 -M' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 16 -M')
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 32' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 64' )
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 32 -M' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 64 -M')
#learners=('neuralNetworks.MultiMLP -d CPU -h -n -o 10 -O 10 -R -P P30 -B 1')
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 1' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 4' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 8' 'neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 16')

# 2/30 MLPs setting
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 2 -O 2 -R -P P30 -B 1')
# 4/30 MLPs setting
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 4 -O 4 -R -P P30 -B 1')
# 6/30 MLPs setting
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 6 -O 6 -R -P P30 -B 1')
# 8/30 MLPs setting
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 8 -O 8 -R -P P30 -B 1')
# 10/30 MLPs setting
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 1')

# 10/30 MLPs setting Mini Batch
#batch size 4 s
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 4')
#batch size 16 s
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 16')
#batch size 32 s
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 32')

# Multiple iterations
#batch size 4 s
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 4 -M')
#batch size 16 s
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 16 -M')
#batch size 32 s
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 32 -M')

# 10/30 MLPs setting Skip BP
# bp = 0.3
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 1 -b 0.3')
# bp = 0.6
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 1 -b 0.6')
# bp = 0.9
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 1 -b 0.9')

# Selected: 10/30, Minibatch 4, bp=0.3
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 10 -O 10 -R -P P30 -B 4 -b 0.3')
# Selected: 8/30, Minibatch 4, bp=0.3
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 8 -O 8 -R -P P30 -B 4 -b 0.3')
# Selected: 6/30, Minibatch 4, bp=0.3
#learners=('neuralNetworks.MultiMLP -d GPU -h -n -o 6 -O 6 -R -P P30 -B 4 -b 0.3')

#####################################################################################################
# SGT
#learners=('trees.StreamingGradientTreePredictor')
# SGT reset on drift
learners=('moa.classifiers.drift.SingleClassifierDrift -l trees.StreamingGradientTreePredictor -d (ADWINChangeDetector -a 1.0E-6)')

#learners=('trees.StreamingGradientTreePredictor' 'moa.classifiers.drift.SingleClassifierDrift -l trees.StreamingGradientTreePredictor -d (ADWINChangeDetector -a 1.0E-6)')
#####################################################################################################
# Boosting
# delta
#learners=('moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor -D 0.1)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor -D 0.01)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor -D 0.001)')

# gamma
#learners=('moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor -Y 1)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor -Y 2)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor -Y 4)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor -Y 8)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor -Y 16)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor -Y 32)')

# ensemble size and learning rate
learners=('moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -L 0.1' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -L 0.1' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -L 0.1' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -L 0.1' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -L 0.01' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -L 0.01' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -L 0.01' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -L 0.01' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -L 0.001' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -L 0.001' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -L 0.001' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -L 0.001')
# 50 and 100 ensemble for above
#learners=('moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -L 0.1' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -L 0.01' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -L 0.001' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.1' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.01' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.001')

# ensemble size, learning rate and reset
#learners=('moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -r -L 0.1' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -r -L 0.1' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -r -L 0.1' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -r -L 0.1' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -r -L 0.01' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -r -L 0.01' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -r -L 0.01' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -r -L 0.01' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -r -L 0.001' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -r -L 0.001' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -r -L 0.001' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -r -L 0.001')
# 50 and 100 ensemble for above
#learners=('moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -L 0.1 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -L 0.01 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -L 0.001 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.1 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.01 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.001 -r')

# ensemble size and learning rate subspace 60
#learners=('moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -L 0.1 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -L 0.1 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -L 0.1 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -L 0.1 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -L 0.1 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.1 -m 60')
#learners=('moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -L 0.001 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -L 0.001 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -L 0.001 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -L 0.001 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -L 0.001 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.001 -m 60')

# ensemble size, learning rate and reset subspace 60
#learners=('moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -r -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -r -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -r -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -r -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -r -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -r -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -r -L 0.1 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -r -L 0.1 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -r -L 0.1 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -r -L 0.1 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -r -L 0.1 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -r -L 0.1 -m 60')
#learners=('moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -r -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -r -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -r -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -r -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -r -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -r -L 0.01 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 5 -r -L 0.001 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 10 -r -L 0.001 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 20 -r -L 0.001 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 30 -r -L 0.001 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 50 -r -L 0.001 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -r -L 0.001 -m 60')

# weighted boosting FIMTDD
# -g
#learners=('moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 10 -c 0.01 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 15 -c 0.01 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.01 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 50 -c 0.01 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 75 -c 0.01 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 100 -c 0.01 -e -p)) -s 1 -L 0.025')
# -c
#learners=('moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.1 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.01 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.001 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.5 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.005 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.75 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.075 -e -p)) -s 1 -L 0.025' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.0075 -e -p)) -s 1 -L 0.025')
#####################################################################################################
# Ensemble Learners
#learners=('meta.AdaptiveRandomForest -j 10' 'meta.StreamingRandomPatches')
#learners=('meta.StreamingRandomPatches' 'meta.StreamingRandomPatches -s 30')
# SRP with SGT
#learners=('meta.StreamingRandomPatches -l trees.StreamingGradientTreePredictor')
#learners=('meta.StreamingRandomPatches -l trees.StreamingGradientTreePredictor -s 30')
#learners=('meta.StreamingRandomPatches -l trees.StreamingGradientTreePredictor' 'meta.StreamingRandomPatches -l trees.StreamingGradientTreePredictor -s 30')
#learners=('meta.StreamingRandomPatches -s 75')
#####################################################################################################
# Weighted boosting
# Weighted boosting FIMTDD configs with different LRs search with s 100 compared with s 1
learners=('moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.75 -e -p)) -s 100 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.75 -e -p)) -s 100 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.75 -e -p)) -s 100 -L 0.0025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.75 -e -p)) -s 1 -L 0.025 -m 60')
learners=('moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 50 -c 0.01 -e -p)) -s 100 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 50 -c 0.01 -e -p)) -s 100 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 50 -c 0.01 -e -p)) -s 100 -L 0.0025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 50 -c 0.01 -e -p)) -s 1 -L 0.025 -m 60')
learners=('moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.0025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 1 -L 0.025 -m 60')
# Weighted boosting FIMTDD configs with different LRs search with s 75 compared with s 1
learners=('moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.75 -e -p)) -s 75 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.75 -e -p)) -s 75 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.75 -e -p)) -s 75 -L 0.0025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.75 -e -p)) -s 1 -L 0.025 -m 60')
learners=('moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 50 -c 0.01 -e -p)) -s 75 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 50 -c 0.01 -e -p)) -s 75 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 50 -c 0.01 -e -p)) -s 75 -L 0.0025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 50 -c 0.01 -e -p)) -s 1 -L 0.025 -m 60')
learners=('moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 75 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 75 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 75 -L 0.0025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 1 -L 0.025 -m 60')
# Weighted boosting FIMTDD configs search  with s 75 , L 0.025 compared with s 1
learners=('moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 75 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.HoeffdingRegressionTree -k -v -n HoeffdingNumericAttributeClassObserver -d HoeffdingNominalAttributeClassObserver -g 25 -c 0.05)) -s 75 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 1 -L 0.025 -m 60')
# Weighted boosting HTR configs search  with s 75 , L 0.025 compared with s 1
learners=('moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.HoeffdingRegressionTree -k -v -n HoeffdingNumericAttributeClassObserver -d HoeffdingNominalAttributeClassObserver -g 25 -c 0.05)) -s 75 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.HoeffdingRegressionTree -k -v -n HoeffdingNumericAttributeClassObserver -d HoeffdingNominalAttributeClassObserver -g 50 -c 0.01)) -s 75 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.HoeffdingRegressionTree -k -v -n HoeffdingNumericAttributeClassObserver -d HoeffdingNominalAttributeClassObserver -g 25 -c 0.75)) -s 75 -L 0.025 -m 60')
# Boosting with SGT and Weighted boosting with SGT compared with s 1
#learners=(\
#'trees.StreamingGradientTreePredictor' \
#'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.025 -m 60' \
#'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60' \
#'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.025 -m 60' \
#'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60' \
#'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 1 -L 0.025 -m 60')

learners=('meta.StreamingRandomPatches' \
'trees.StreamingGradientTreePredictor' \
'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 1 -L 0.025 -m 60' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.025 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.025 -m 60 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60 -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.025 -m 60 -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60 -r' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.25 -m 60' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.25 -m 60 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.25 -m 60 -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.25 -m 60 -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.25 -m 60 -r' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r')

learners=(\
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.25 -m 60' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.25 -m 60' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.25 -m 60 -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.25 -m 60 -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.25 -m 60 -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.25 -m 60 -r' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4)' \
'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 75 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 75 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r' 'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.25 -m 60 -x (ADWINChangeDetector -a 1.0E-4) -r'\
)


#learners=(\
#'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 75 -L 0.025 -m 60' \
#'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.025 -m 60')

learners=(\
'meta.StreamingRandomPatches' \
'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.025 -m 60' \
'moa.classifiers.meta.Boosting -s 100 -L 0.025 -m 60' \
'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60' \
'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60' \
'meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.025 -m 60' \
'meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.025 -m 60' \
'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.HoeffdingRegressionTree -k -v -n HoeffdingNumericAttributeClassObserver -d HoeffdingNominalAttributeClassObserver -g 25 -c 0.05)) -s 100 -L 0.025 -m 60' \
'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.HoeffdingRegressionTree -k -v -n HoeffdingNumericAttributeClassObserver -d HoeffdingNominalAttributeClassObserver -g 25 -c 0.05)) -s 100 -L 0.025 -m 60' \
)

learners=(\
'meta.StreamingRandomPatches' \
'moa.classifiers.meta.Boosting -s 100 -L 0.025 -m 60' \
'moa.classifiers.meta.Boosting -w -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60' \
'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor)) -s 100 -L 0.025 -m 60'\
)

learners=(\
'meta.Boosting -s 100 -L 0.025 -m 60' \
'meta.Boosting -N -s 100 -L 0.025 -m 60' \
'meta.Boosting -N -C -s 100 -L 0.025 -m 60' \
'meta.Boosting -w -W -l (trees.BoostingTreePredictor -l trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60' \
'meta.Boosting -N -w -W -l (trees.BoostingTreePredictor -l trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60' \
'meta.Boosting -N -C -w -W -l (trees.BoostingTreePredictor -l trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60'\
)

learners=(\
'meta.Boosting -N -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60' \
'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -D 0.5) -s 100 -L 0.025 -m 60' \
'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -D 0.05) -s 100 -L 0.025 -m 60' \
'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -D 0.005) -s 100 -L 0.025 -m 60'\
)

#learners=(\
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -L 0.005) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -L 0.05) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -L 0.5) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -L 1.0) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -L 5.0) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -L 50.0) -s 100 -L 0.025 -m 60'\
#)

#learners=(\
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -Y 0.005) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -Y 0.05) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -Y 0.5) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -Y 1.0) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -Y 5.0) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -Y 50.0) -s 100 -L 0.025 -m 60'\
#)


#learners=(\
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -G 25) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -G 50) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -G 100) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -G 150) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -G 200) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -G 250) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -G 300) -s 100 -L 0.025 -m 60'\
#)


#learners=(\
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -L 1.0 -Y 5.0 -G 25) -s 100 -L 0.025 -m 60'\
#)

#learners=(\
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 50' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 70' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 80' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor) -s 100 -L 0.025 -m 100'\
#)
#
#learners=(\
#'meta.StreamingRandomPatches -m 50' \
#'meta.StreamingRandomPatches -m 60' \
#'meta.StreamingRandomPatches -m 70' \
#'meta.StreamingRandomPatches -m 80' \
#'meta.StreamingRandomPatches -m 100'\
#)

#learners=(\
#'meta.StreamingRandomPatches' \
#'trees.StreamingGradientTreePredictor -D 0.05 -L 0.05 -Y 0.5 -G 200' \
#'meta.Boosting -N -l (trees.StreamingGradientTreePredictor -D 0.05 -L 0.05 -Y 0.5 -G 200) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor -D 0.05 -L 0.05 -Y 0.5 -G 200)) -s 100 -L 0.025 -m 60' \
#'meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.025 -m 60' \
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.025 -m 60' \
#)

#learners=(\
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.025 -m 60 -G 25000 -E 5000 -B 1.0' \
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.025 -m 60 -G 25000 -E 5000 -B 5.0' \
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.025 -m 60 -G 25000 -E 5000 -B 10.0' \
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.025 -m 60 -G 25000 -E 5000 -B 15.0' \
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.025 -m 60 -G 25000 -E 5000 -B 20.0'\
#)

#learners=(\
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.1 -m 60 -D' \
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.075 -m 60 -D' \
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.05 -m 60 -D' \
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.025 -m 60 -D'\
#)

#learners=(\
#'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.0125 -m 60' \
#'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.0125 -m 60' \
#'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor -D 0.05 -L 0.05 -Y 0.5 -W 400)) -s 100 -L 0.0125 -m 60' \
#'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (drift.DriftDetectionMethodClassifier -l (trees.StreamingGradientTreePredictor -D 0.05 -L 0.05 -Y 0.5 -W 400) -d (DDM -n 250 -o 2.5))) -s 100 -L 0.0125 -m 60' \
#'meta.StreamingRandomPatches'\
#)


learners=(\
'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.0125 -m 60' \
'meta.StreamingRandomPatches' \
'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.0125 -m 60 -h' \
'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.StreamingGradientTreePredictor -D 0.05 -L 0.05 -Y 0.5 -W 400)) -s 100 -L 0.0125 -m 60' \
'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (drift.DriftDetectionMethodClassifier -l (trees.StreamingGradientTreePredictor -D 0.05 -L 0.05 -Y 0.5 -W 400) -d (DDM -n 250 -o 2.5))) -s 100 -L 0.0125 -m 60' \
'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (drift.DriftDetectionMethodClassifier -l (trees.StreamingGradientTreePredictor -D 0.05 -L 0.05 -Y 0.5 -W 400) -d (DDM -n 250 -o 2.5))) -s 100 -L 0.0125 -m 60 -h' \
'moa.classifiers.meta.Boosting -w -W -H -s 100 -L 0.0125 -m 60'\
)

learners=(\
'meta.AdIterVotesReader'\
)

learners=(\
'moa.classifiers.meta.Boosting -w -W -l (trees.BoostingTreePredictor -l (trees.FIMTDD -s VarianceReductionSplitCriterion -g 25 -c 0.05 -e -p)) -s 100 -L 0.0125 -m 60' \
)


#####################################################################################################
# Evaluation method
# for Final results
evaluation_type='EvaluateInterleavedTestThenTrain'
# for graphs
#evaluation_type='EvaluatePrequential'

g_sample_frequency=1000000
use_10_percent_sample_frequency=0
if [ "$evaluation_type" = "EvaluatePrequential" ] ; then
  g_sample_frequency=1000
  use_10_percent_sample_frequency=0
fi
g_max_instances=1000000
#####################################################################################################

if [ $# -lt 2 ]; then
  print_usage
  exit 1
fi

dataset_dir=$1
out_csv_dir=$2

if [ $# -gt 2 ]; then
  if [ -d "$3" ]; then
    export DJL_CACHE_DIR=$3
  else
    echo "DJL_CACHE_DIR can not be set. Directory $3 is not available."
    print_usage
    exit 1
  fi
fi

MAVEN_REPO="$(realpath ~)/.m2/repository"
if [ $# -gt 3 ]; then
  if [ -d "$4" ]; then
    MAVEN_REPO="$4"
    export MAVEN_OPTS="-Dmaven.repo.local=$4"
  else
    echo "MAVEN_OPTS=-Dmaven.repo.local can not be set. Directory $4 is not available."
    print_usage
    exit 1
  fi
fi


#for f in $( find "${MAVEN_REPO}/org/slf4j/" -name "*1.5.6*" );
#do
#  echo "Removing $f"
#  rm -r "$f"
#done


if [ $# -gt 4 ]; then
  eval "$(conda shell.bash hook)"
  conda init bash
  conda activate "$5"
  conda env list
fi

VOTES_DIR=''
if [ $# -gt 5 ]; then
  if [ -d "$6" ]; then
    VOTES_DIR="$6"
  fi
fi
echo "Votes dir: $VOTES_DIR"

#BASEDIR=`dirname $0`/..
#BASEDIR=`(cd "$BASEDIR"; pwd)`
#REPO=$BASEDIR/../../target/classes
#JAR_PATHS="$(for j in $(find $MAVEN_REPO -name '*.jar');do printf '%s:' $j; done)"
JAR_PATHS="$(find $MAVEN_REPO -name '*moa-*SNAPSHOT.jar'| grep -v 'kafka')"
#CLASSPATH="$JAR_PATHS$REPO/"
CLASSPATH="$JAR_PATHS"
JAVA_AGENT_PATH="$(find $MAVEN_REPO -name 'sizeofag-1.0.4.jar')"


JCMD=java
case $(uname)  in

  Darwin)
    if [ -f "$(/usr/libexec/java_home -v 1.8.0_271)/bin/java" ]
    then
      JCMD="$(/usr/libexec/java_home -v 1.8.0_271)/bin/java"
    fi
    echo "MacOS"
    ;;

  Linux)
    if [ -f "$JAVA_HOME/bin/java" ]
    then
      JCMD="$JAVA_HOME/bin/java"
    fi
    echo "Linux"
    ;;

  *)
    JCMD=java
    ;;
esac

log_file="${out_csv_dir}/full.log"
echo "Full results log file = $log_file"
rm -f $log_file

declare -a repeat_exp_count
for i in "${datasets_to_repeat[@]}"
do
    repeat_exp_count+=(${max_repeat})
done

for learner in "${learners[@]}";
do
  re_run_count=0
  task_failed=0

  for (( i=0; i<${#dataset[@]}; i++ ))
  do
    sleep 10
    task_failed=0
    echo "======================================================================================="
    echo "Dataset = ${dataset[$i]}"
    votes_file=''
    learner_prefix="${learner// /}"

    in_file="${dataset_dir}/${dataset[$i]}.arff"

    in_file_lines=$(wc -l $in_file |awk '{print $1}')
    in_file_desc_lines=$(grep -h -n '@data' "$in_file" | awk -F ':' '{print $1}')
    total_number_of_instances=$((in_file_lines - in_file_desc_lines -1))

    stream_dir="${dataset[$i]}"
#    out_file_post_fix=''
    stream="-s (ArffFileStream -f $in_file)"
    max_instances=$((g_max_instances))
    sample_frequency=$((g_sample_frequency))
    if [[ $(echo "${dataset[$i]}" | grep -c 'RandomTreeGenerator\|RBF\|AGR\|LED') -gt 0 ]]; then
      if [[ $use_full_generator_for_synthetic -eq 1 || $use_scaled_generator_for_synthetic -eq 1 ]]; then
        if [ $use_scaled_generator_for_synthetic -eq 1 ]; then
#          out_file_post_fix='S10'
          temp_v_name="${dataset[$i]}_S_10"
          stream_dir="${temp_v_name}"
          stream="${!temp_v_name}"
          max_instances=$((max_instances/10))
          total_number_of_instances=$((total_number_of_instances/10))
          if [ "$evaluation_type" = "EvaluateInterleavedTestThenTrain" ] ; then
            sample_frequency=$((max_instances))
          fi
        else
#          out_file_post_fix='S'
          temp_v_name="${dataset[$i]}_S"
          stream_dir="${temp_v_name}"
          stream="${!temp_v_name}"
        fi
      fi
    else
      # not synthetic
      if [ $use_datasets_without_drifts -eq 1 ]; then
#        out_file_post_fix="${random_seed}"
        stream_dir="${dataset[$i]}-${random_seed}"
        stream="-s (ArffFileStream -f ${dataset_dir}/${dataset[$i]}RANDOM${random_seed}.arff)"
      else
        echo ' trees.HoeffdingTree' | grep -c '^trees.HoeffdingTree\|trees.StreamingGradientTreePredictor'
        if [[ $(echo "${learner}" | grep -c '^trees.HoeffdingTree\|trees.StreamingGradientTreePredictor') -gt 0 ]]; then
          echo "Random seed change not allowed for ${learner}"
        else
          learner="$learner -Z ${random_seed}"
        fi
      fi
    fi

    warmup_instances=$((total_number_of_instances /100))
    if [ $use_10_percent_sample_frequency -eq 1 ]; then
      sample_frequency=$((warmup_instances * 10))
    fi
    if [ $warmup_instances -gt 1000 ]; then
      warmup_instances=1000
    fi

    case $learner in
    neuralNetworks.MultiMLP*)
        learner_command="$learner -s $warmup_instances"
        ;;
    neuralNetworks.ReadVotes*)
        votes_file="$(find $VOTES_DIR -name *${dataset[$i]}_NN_votes.csv)"
        learner_command="$learner -f $votes_file"
        ;;
    neuralNetworks.ADLVotesReader*)
        votes_file="$(find $VOTES_DIR -name *${dataset[$i]}_predictions.csv)"
        learner_command="$learner -f $votes_file"
        ;;
    meta.AdIterVotesReader*)
        votes_file="$(find $VOTES_DIR -name *${dataset[$i]}${random_seed}_votes.csv)"
        learner_command="$learner -f $votes_file -S 100"
        if [[ $(echo "${dataset[$i]}" | grep -c 'RandomTreeGenerator\|RBF\|AGR\|LED') -gt 0 ]]; then
          adIter_learner_command_for_log="$learner ${random_seed} -s 100"
        else
          adIter_learner_command_for_log="$learner -s 100"
        fi
        ;;
#    meta.AdaptiveRandomForest1*|meta.StreamingRandomPatches1*)
#        learner_command="$learner -r $random_seed"
#        ;;
    *)
        learner_command="$learner"
        ;;
    esac

    stream_dir="${stream_dir// /_}"
    if [ -d "${stream_dir}" ]; then
      echo "Directory ${out_csv_dir}/${stream_dir} available"
    else
      mkdir -p "${out_csv_dir}/${stream_dir}"
    fi

    if [[ $(echo "$learner" | grep -c 'meta.AdIterVotesReader') -gt 0 ]]; then
      out_file="${out_csv_dir}/${stream_dir}/${adIter_learner_command_for_log// /_}.csv"
      tmp_log_file="${out_csv_dir}/${stream_dir}/${adIter_learner_command_for_log// /_}.log"
    else
      out_file="${out_csv_dir}/${stream_dir}/${learner_command// /_}.csv"
      tmp_log_file="${out_csv_dir}/${stream_dir}/${learner_command// /_}.log"
    fi

    if [ -f $out_file ]; then
      echo "$out_file already available"
    fi

    rm -f $tmp_log_file

    if [ -f NN_loss.csv ]; then
      rm -f NN_loss.csv
    fi

    if [ -f NN_votes.csv ]; then
      rm -f NN_votes.csv
    fi

    export "CUDA_VISIBLE_DEVICES=$GPUs_to_use"

    exp_cmd="moa.DoTask \"$evaluation_type -l ($learner_command) $stream -i $max_instances -f $sample_frequency -q $sample_frequency -d $out_file\" &>$tmp_log_file &"
    echo -e "$JCMD -classpath $CLASSPATH -Xmx56g -Xms50m -Xss1g -javaagent:$JAVA_AGENT_PATH"
    echo -e "\n$exp_cmd\n"
    echo -e "\n$exp_cmd\n" > $tmp_log_file
  #taskset -c "$CPUs_to_use"
  time "$JCMD" \
    -classpath "$CLASSPATH" \
    -Xmx56g -Xms50m -Xss1g \
    -javaagent:"$JAVA_AGENT_PATH" \
    moa.DoTask "$evaluation_type -l ($learner_command) $stream -i $max_instances -f $sample_frequency -q $sample_frequency -d $out_file" &>$tmp_log_file &

    if [ -z $! ]; then
      task_failed=1
    else
      PID=$!
      echo -e "PID=$PID : $exp_cmd \n"
      sleep 5

      while [ $(grep -m 1 -c 'Task completed' $tmp_log_file ) -lt 1 ];
      do
        sleep 10
        if ! ps -p $PID &>/dev/null;
        then
          task_failed=1
          break
        esle
          echo -ne "Waiting for exp with $PID to finish\r"
        fi
      done

      echo "Child processors of PID $PID----------------------"
      # This is process id, parameter passed by user
      ppid=$PID

      if [ -z $ppid ] ; then
         echo "No PID given."
      fi

      child_process_count=1
      while true
      do
        FORLOOP=FALSE
        # Get all the child process id
        for c_pid in `ps -ef| awk '$3 == '$ppid' { print $2 }'`
        do
          if [ $c_pid -ne $SCRIPT_PID ] ; then
            child_pid[$child_process_count]=$c_pid
            child_process_count=$((child_process_count + 1))
            ppid=$c_pid
            FORLOOP=TRUE
          else
            echo "Skip adding PID $SCRIPT_PID"
          fi
        done
        if [ "$FORLOOP" = "FALSE" ] ; then
           child_process_count=$((child_process_count - 1))
           ## We want to kill child process id first and then parent id's
           while [ $child_process_count -ne 0 ]
           do
             echo "killing ${child_pid[$child_process_count]}"
             kill -9 "${child_pid[$child_process_count]}" >/dev/null
             child_process_count=$((child_process_count - 1))
           done
         break
        fi
      done
      echo "Child processors of PID $PID----------------------"
      echo -e "killing PID $PID\n"
      kill $PID
    fi

    if [ -f NN_loss.csv ]; then
      mv NN_loss.csv "${learner_prefix}_${dataset[$i]}_NN_loss.csv"
    fi

    if [ -f NN_votes.csv ]; then
      mv NN_votes.csv "${learner_prefix}_${dataset[$i]}_NN_votes.csv"
    fi

    cat $tmp_log_file >> $log_file

    if [ $task_failed -eq 0 ]; then
      re_run_count=0
      echo -e "Task=$i dataset=${dataset[$i]} PID=$PID ) was successful.\n"
      for (( j=0; j<${#datasets_to_repeat[@]}; j++ ))
      do
        if [ "${dataset[$i]}" == "${datasets_to_repeat[$j]}" ]; then
          if [ $((${repeat_exp_count[$j]})) -gt 0 ]; then
            repeat_exp_count[$j]=$((${repeat_exp_count[$j]} - 1))
            echo "Repeat ${dataset[$i]} for the $((max_repeat - ${repeat_exp_count[$j]})) time"
            i=$((i-1))
            break
          fi
        fi
      done
    else
      echo "Task=$i dataset=${dataset[$i]} PID=$PID ) failed."
      if [ $re_run_count -lt $max_re_run_count ]; then
        re_run_count=$((re_run_count+1))
        echo "Re-running it for the $re_run_count time."
        i=$((i-1))
      else
        echo "Not Re-running it for the $((re_run_count+1)) time."
        re_run_count=0
      fi
    fi

  done
done
