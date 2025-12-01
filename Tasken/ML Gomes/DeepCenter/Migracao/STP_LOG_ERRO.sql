  
  
CREATE PROCEDURE STP_LOG_ERRO @PROCESSO VARCHAR(100)  
AS    
BEGIN  
 IF OBJECT_ID('TBL_LOG_JOB') IS NULL  
 BEGIN  
  CREATE TABLE TBL_LOG_JOB  
  (  
  Id INT IDENTITY(1,1)  
  ,Processo VARCHAR(100)  
  ,ErrorNumber VARCHAR(100)  
  ,ErrorSeverity VARCHAR(100)  
  ,ErrorState VARCHAR(100)  
  ,ErrorProcedure VARCHAR(100)  
  ,ErrorLine VARCHAR(100)  
  ,ErrorMessage VARCHAR(100)  
  ,DataLog DATETIME CONSTRAINT DtLogErroJob default(getdate())  
  
  )  
 END  
  
 INSERT INTO TBL_LOG_JOB  
 (  
 Processo  
 ,ErrorNumber  
 ,ErrorSeverity  
 ,ErrorState  
 ,ErrorProcedure  
 ,ErrorLine  
 ,ErrorMessage  
  
 )  
  
  
 SELECT  
  @PROCESSO    
  ,ERROR_NUMBER() AS ErrorNumber    
  ,ERROR_SEVERITY() AS ErrorSeverity    
  ,ERROR_STATE() AS ErrorState    
  ,ERROR_PROCEDURE() AS ErrorProcedure    
  ,ERROR_LINE() AS ErrorLine    
  ,ERROR_MESSAGE() AS ErrorMessage;     
END