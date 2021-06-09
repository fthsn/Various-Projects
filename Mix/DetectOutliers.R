####################################################################
## Function FthsnGetOutliers
########################################
########################################
FthsnGetOutliers = function(data='mydata',vl='',plimit=0.0001) {
  
  # data = 'mydata'
  # ii = 'Crp'

  data = data.frame(get(data))
  
  print('########### 1st Round ')
  for (ii in vl) {
    var = ii
    # print(ii)
    frml = as.formula(paste(var,' ~ 1'))
    mod = lm(frml,data=data)
    cooksd = cooks.distance(mod);
    # text(cooksd,row.names(cooksd))
    influential <- as.numeric(names(cooksd)[(cooksd > (4/nrow(data)))])
    
    oudt = data.table(car::outlierTest(mod,cutoff=plimit)$bonf.p)
    oudt$names = names(car::outlierTest(mod,cutoff=plimit)$bonf.p)
    oudt = oudt[V1<plimit]
    # if (nrow(oudt)==0) {oudt=0}
    
    outliers = as.numeric(oudt$names)
    detected = intersect(influential,outliers)
    if(length(detected)>0) {plot(cooksd,main = var);}
    
    
    x = data[-detected,var]
    if(length(detected)>0) { 
    print(paste(ii,'(',paste(data[detected,var],collapse = ', '),')'))
    }
    for (i in detected) {
      a = data[i,var]  
      w = which(abs(x-a)==min(abs(x-a),na.rm = TRUE))
      data[i,var]  =  mean(x[w],na.rm = TRUE)
      # print(paste(i,a,mean(x[w])))
      
    }
  }
  print('########### 2nd Round ')
  # plimit = 0.01
  for (ii in vl) {
    var = ii
    # print(ii)
    frml = as.formula(paste(var,' ~ 1'))
    mod = lm(frml,data=data)
    cooksd = cooks.distance(mod);
    # text(cooksd,row.names(cooksd))
    influential <- as.numeric(names(cooksd)[(cooksd > (4/nrow(data)))])
    
    oudt = data.table(car::outlierTest(mod,cutoff=plimit)$bonf.p)
    oudt$names = names(car::outlierTest(mod,cutoff=plimit)$bonf.p)
    oudt = oudt[V1<plimit]
    # if (nrow(oudt)==0) {oudt=0}
    
    outliers = as.numeric(oudt$names)
    detected = intersect(influential,outliers)
    if(length(detected)>0) {plot(cooksd,main = var);}
    
    
    x = data[-detected,var]
    if(length(detected)>0) { 
      print(paste(ii,'(',paste(data[detected,var],collapse = ', '),')'))
    }
    for (i in detected) {
      a = data[i,var]  
      w = which(abs(x-a)==min(abs(x-a),na.rm = TRUE))
      data[i,var]  =  mean(x[w],na.rm = TRUE)
      # print(paste(i,a,mean(x[w])))
      
    }
  }
  
  print('########### 3th Round ')
  # plimit = 0.01
  for (ii in vl) {
    var = ii
    # print(ii)
    frml = as.formula(paste(var,' ~ 1'))
    mod = lm(frml,data=data)
    cooksd = cooks.distance(mod);
    # text(cooksd,row.names(cooksd))
    influential <- as.numeric(names(cooksd)[(cooksd > (4/nrow(data)))])
    
    oudt = data.table(car::outlierTest(mod,cutoff=plimit)$bonf.p)
    oudt$names = names(car::outlierTest(mod,cutoff=plimit)$bonf.p)
    oudt = oudt[V1<plimit]
    # if (nrow(oudt)==0) {oudt=0}
    
    outliers = as.numeric(oudt$names)
    detected = intersect(influential,outliers)
    if(length(detected)>0) {plot(cooksd,main = var);}
    
    
    x = data[-detected,var]
    if(length(detected)>0) { 
      print(paste(ii,'(',paste(data[detected,var],collapse = ', '),')'))
    }
    for (i in detected) {
      a = data[i,var]  
      w = which(abs(x-a)==min(abs(x-a),na.rm = TRUE))
      data[i,var]  =  mean(x[w],na.rm = TRUE)
      # print(paste(i,a,mean(x[w])))
      
    }
  }
  
  
  
  
 
  
  return(data.table(data))}
