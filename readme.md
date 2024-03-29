# GLUE Benchmark (STS-B and CoLA)

This is a readme file for the course project of *Natural Language Processing*, CS229, by Prof. Hai Zhao.

* **Author:** Zhanghao Wu (516030910593)
* **Email:** wz.wzh@sjtu.edu.cn
* **Affiliation:** ACM Honored Class, Zhiyuan College, SJTU

I will introduce the two models I used for this task, including BERT[1], MT-DNN[2] and XLNet[3]. And I will then showing how to run the codes. Also the result on the public GLUE benchmark is shown in the appendix at the bottom.

## Models
### Pretrained BERT

BERT[1] is a language representation model proposed by Devlin *et al.* from *Google inc*. BERT takes advantages of attention mechanism with unsupervised (or natural supervised as mentioned by Prof. Zhao) training on very large unlabeled datasets, like wikipedia.

With the codebase from [huggingface/pytorch-pretrained-BERT](https://github.com/huggingface/pytorch-pretrained-BERT.git), I rewrite the finetuning process, making the program automatically finding the best epoch on dev set when training and output the test results with the best model and the ensemble result with the model got from 3 epochs near the best epoch.

For this part, I tried both the cased model and the uncased model. It turns out that the cased model has a degradation on performance, which may caused by lacking of enough training data, since the cased model should *see* more examples to learn the task.

### MT-DNN

I also tried a improved version of BERT, called MT-DNN[2] proposed by Liu *et al.* from the *Microsoft Inc*. The model used multi-task for learning representation across multiple natural language understanding (NLU) tasks with BERT as the backbone. The basic idea for this architecture is that multi-task helps the BERT to adapt to certain target domain.

With the codebase from [namisan/mt-dnn](https://github.com/namisan/mt-dnn.git), I got a better results on both STS-B and CoLA tasks. The reason for the improvement relies on that the MT-DNN can learn from the correlation between different tasks, like sharing some information between CoLA and SST-2.

The MT-DNN model improve the Pearson/Spearman Correlation from 87.1/86.0 to 89.9/89.2 and the Matthew Correlation on CoLA from 57.3 to 60.1 on test set. By ensemble the MT-DNN with the single-task finetuned BERT, I got a further better result on STS-B, 89.9/89.2. The results are shown in the table below.

### XLNet

XLNet[3] is newly proposed on 19 Jun, 2019. Integrating ideas from Transformer-XL, the state-of-the-art autoregressive model, into pretraining, XLNet outperforms the traditional bert and the MT-DNN, which only relies on corrupting the input with masks.

With the codebase from [zihangdai/xlnet](https://github.com/zihangdai/xlnet.git), I finetuned the pretrained model on the STS-B and CoLA training set on 4 RTX2080Ti. The STS-B task is further improved to 90.2/89.9 on test set. However, on the CoLA task, the author finetuned the model with a batch size 128, which requires a lot of GPU memory and is quite impractical without a large amount of TPUs. I tried to add gradient accumulation for the base code, but since I am not familiar with tensorflow, I failed.  However, I may try to reproduce the result with pytorch in the future.

## Results
| STS-B (model) | Pearson/Spearman Correlation |
|:--------|:------:|
| Bert-large-cased                              |  85.9/84.8  |
| Bert-large-uncased                            |  87.1/86.0  |
| ensemble cased and uncased                    |  87.4/86.3  |
| **MT-DNN**                                    |  89.4/88.6  |
| **XLNet**                                     |  90.2/89.9  |
| **ensemble MT-DNN with BERT**                 |  **89.9/89.2**  |
| **ensemble XLNet with MT-DNN**                |  **91.0/90.6**  |

| CoLA (model) | Matthew Correlation |
|:---|:---:|
| BERT-large-uncased                             |  57.3       |
| **XLNet**                                      |    -        |
| **MT-DNN**                                     |  **60.1**   |


## Get Started
To run the code more conveniently, I wrote some shell scripts for installation, training and testing. The steps to use install the environment, training the model and testing are shown below. PS, since the finetuned models are quite large, I only put the MT-DNN model for CoLA and XLNet model for STS-B in the zip. Please contact me if you need the model of finetuned BERT.

### Prerequisite
1. BERT
   ```bash
   cd ./pytorch-pretrained-BERT
   pip install -r requirements.txt
   pip install --editable .
   python ./download_glue_data.py
   ```
2. MT-DNN
   ```bash
   cd ./mt-dnn
   pip install -r requrirements.txt
   ./download.sh
   python ./preproc.py
   ```

3. XLNet
    ```bash
   cd ./xlnet
   conda create -n xlnet python=2 tensorflow=1.13
   ln -s ../pytorch_pretrained_bert/glue_data

   # Download XLNet pretrained model (optional)
   wget https://storage.googleapis.com/xlnet/released_models/cased_L-24_H-1024_A-16.zip
   mkdir ./checkpoints
   mv ./cased_L-24_H-1024_A-16.zip ./checkpoints
   unzip ./checkpoints/cased_L-24_H-1024_A-16.zip
    ```

### Training
1. BERT
   ```bash
   cd ./pytorch-pretrained-BERT
   # Finetune pretrained BERT for STS-B
   ./run_stsb.sh
   # Finteune pretrained BERT for CoLA
   ./run_cola.sh
   ```
2. MT-DNN
   ```bash
   cd ./mt-dnn/scripts
   # Train MT-DNN model (not necessary using the pretrained one)
   ./run_mt_dnn.sh
   # Finetune pretrained MT-DNN for STS-B
   ./run_stsb.sh 32 0,1,2,3
   # Finetune pretrained MT-DNN for CoLA
   ./run_cola.sh 32 0,1,2,3
   ```

3. XLNet
    ```bash
    cd ./xlnet
    # Finetune XLNet for STS-B
    ./train_stsb.sh
    # train_cola.sh is also provided but you should use TUPs to support the train option: batch_size=128
    ```

   
### Testing
1. BERT
   ```bash
   cd ./pytorch-pretrained-BERT
   # Test STS-B with the my pretrained checkpoint
   ./test_stsb.sh
   # Test CoLA with the my pretrained checkpoint
   ./test_cola.sh
   ```
2. MT-DNN
   ```bash
   cd ./mt-dnn/scripts
   # Test STS-B with the my pretrained checkpoint
   ./test_stsb.sh 32 0,1,2,3
   # Test CoLA with the my pretrained checkpoint
   ./test_cola.sh 32 0,1,2,3
   ```
3. XLNet
    ```bash
    cd ./xlnet
    # Test STS-B with the my pretrained checkpoint
    ./test_stsb.sh test
    # test_cola.sh (TPUs required)
    ```
## Reference
[1] Devlin, J., Chang, M. W., Lee, K., & Toutanova, K. (2018). BERT: Pre-training of deep bidirectional transformers for language understanding. arXiv preprint arXiv:1810.04805.
 
[2] Liu, X., He, P., Chen, W., & Gao, J. (2019). Multi-Task Deep Neural Networks for Natural Language Understanding. arXiv preprint arXiv:1901.11504.

[3] Zhilin Yang, Zihang Dai, Yiming Yang, Jaime Carbonell, Ruslan Salakhutdinov, & Quoc V. Le. XLNet: Generalized Autoregressive Pretraining for Language Understanding. arXiv preprint arXiv:1906.08237.

## Appendix
![Result](glue_result.jpg)