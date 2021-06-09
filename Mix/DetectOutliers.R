
FthsnGetOutliers = function(data='',vl='') {
data = get(data)

for (ii in vl) {
var = ii
print(ii)
mean(data[,var])
frml = as.formula(paste(var,' ~ 1'))
mod = lm(frml,data=data)
cooksd = cooks.distance(mod);plot(cooksd);text(cooksd,row.names(cooksd))
influential <- as.numeric(names(cooksd)[(cooksd > (4/nrow(data)))])
outliers = as.numeric(names(car::outlierTest(mod)$bonf.p))
detected = intersect(influential,outliers)
x = data[-detected,var]

for (i in detected) {
  a = data[i,var]  
  w = which(abs(x-a)==min(abs(x-a)))
  data[i,var]  =  mean(x[w])
  print(paste(i,a,mean(x[w])))

}
}
return(data.table(data))}

say = colnames(Merged2[,sapply(Merged2,is.numeric)])
 
xx = FthsnGetOutliers('Merged2',"Kadrolu_Ogrt_Oran")

 
