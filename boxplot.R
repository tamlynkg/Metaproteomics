# Give the chart file a name.
png(file = "boxplot.png")

# Plot the chart.

cols <- names(data)[grep("X",names(data))] 

boxplot(contrasts ~ cols ,data = data, xlab = "Inflammed vs Non-Inflammed",
        ylab = "Protein intensity", main = "Proteins across inflammation states")

# Save the file.
dev.off()