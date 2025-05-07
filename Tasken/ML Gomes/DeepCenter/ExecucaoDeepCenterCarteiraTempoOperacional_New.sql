USE [SRC]
GO

/****** Object:  StoredProcedure [dbo].[ExecucaoDeepCenterCarteiraTempoOperacional_New]    Script Date: 07/05/2025 13:44:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ExecucaoDeepCenterCarteiraTempoOperacional_New]    
AS        
BEGIN TRY        
        
 DECLARE @ID_LOG_OUTPUT INT = 0        
         
IF DATEPART(HH, GETDATE()) = 12 AND CONVERT(DATE, GETDATE()) <> '20250501'
	BEGIN
		EXEC stpGravaLogDeepCenter 0, 'COMERCIAL-CARTAO', 'CARTEIRA', @ID_LOG_OUTPUT OUTPUT        
		EXEC ExecucaoDeepCenterBradescoCarteira_New  
		EXEC stpGravaLogDeepCenter @ID_LOG_OUTPUT
	END
          
--EXEC stpGravaLogDeepCenter 0, 'COMERCIAL-CARTAO', 'EXPURGO-CARTEIRA', @ID_LOG_OUTPUT OUTPUT        
--EXEC ExecucaoDeepCenterExpurgoCarteira        
--EXEC stpGravaLogDeepCenter @ID_LOG_OUTPUT   
         
        
 IF DATEPART(HH, GETDATE()) = 22        
 BEGIN           
  EXEC stpGravaLogDeepCenter 0, 'COMERCIAL-CARTAO', 'TEMPOOPERACIONAL', @ID_LOG_OUTPUT OUTPUT        
  EXEC ExecucaoDeepCenterBradescoTempoOperacional_New  
  EXEC stpGravaLogDeepCenter @ID_LOG_OUTPUT           
 END        
        
END TRY        
BEGIN CATCH        
 EXEC STP_LOG_ERRO 'ExecucaoDeepCenterCarteiraTempoOperacional_New'        
END CATCH 
GO


