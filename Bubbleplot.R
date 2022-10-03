#upload your data to R 

pc = read.delim("DEproteins.txt", header = TRUE)
pcm = melt(pc, id = c("Sample"))
colours = c( "#A54657",  "#582630", "#F7EE7F", "#4DAA57","#F1A66A","#F26157", "#F9ECCC", "#679289", "#33658A",
             "#F6AE2D","#86BBD8")
library(ggplot2)
library(reshape2)

xx = ggplot(pcm, aes(x = Sample, y = variable)) + 
  geom_point(aes(size = value, fill = Sample), alpha = 0.75, shape = 21) + 
  scale_size_continuous(limits = c(0.000001, 100), range = c(1,17), breaks = c(1,2,3,7,22)) + 
  labs( x= "", y = "", size = "Differentially expressed proteins", fill = "")  + 
  theme(legend.key=element_blank(), 
        axis.text.x = element_text(colour = "black", size = 12, face = "bold", angle = 90, vjust = 0.3, hjust = 1), 
        axis.text.y = element_text(colour = "black", face = "bold", size = 11), 
        legend.text = element_text(size = 10, face ="bold", colour ="black"), 
        legend.title = element_text(size = 12, face = "bold"), 
        panel.background = element_blank(), panel.border = element_rect(colour = "black", fill = NA, size = 1.2), 
        legend.position = "right") +  
  scale_fill_manual(values = colours, guide = FALSE) + 
  scale_y_discrete(limits = rev(levels(pcm$variable))) 

xx
