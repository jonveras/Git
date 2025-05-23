  
CREATE PROCEDURE [dbo].[ANM_BUSCA_INSTRUCAO] (@INSTRUCAO VARCHAR(200))  
AS  
  
SELECT name,      
 CASE WHEN xtype = 'P'  THEN 'Procedure'      
   WHEN xtype = 'FN' THEN 'Scalar Function'      
   WHEN xtype = 'TR' THEN 'Trigger'      
   WHEN xtype = 'V'  THEN 'View'      
 ELSE xtype END AS TIPO_OBJETO      
FROM syscomments a      
JOIN sysobjects b ON(a.id = b.id)      
WHERE CHARINDEX(LTRIM(RTRIM(@INSTRUCAO)),text)>0      
GROUP BY name,  
 CASE WHEN xtype = 'P' THEN 'Procedure'      
   WHEN xtype = 'FN' THEN 'Scalar Function'      
   WHEN xtype = 'TR' THEN 'Trigger'      
   WHEN xtype = 'V' THEN 'View'      
 ELSE xtype END      
ORDER BY 2,1