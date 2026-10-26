-- 04. Mantenimiento de embeddings: cambio de texto, embedding obsoleto, regeneración y restauración

DECLARE @v VECTOR(1536);
SELECT @v = AI_GENERATE_EMBEDDINGS('warm winter cycling gloves' USE MODEL my_embedding_model);
DECLARE @res TABLE (Etapa NVARCHAR(60), ReviewTitle NVARCHAR(400), Distancia FLOAT);

-- 1. Antes del cambio
INSERT @res SELECT '1. Original', ReviewTitle, VECTOR_DISTANCE('cosine', @v, ReviewVector)
FROM dbo.ProductReview WHERE ReviewID = 124;

-- 2. Texto cambiado, embedding sin actualizar (obsoleto)
UPDATE dbo.ProductReview
SET ReviewText = 'These tires are the most puncture-resistant tires I have ever used. Over 3000 miles with zero flats on rough gravel roads.',
    ReviewTitle = N'Indestructible tires'
WHERE ReviewID = 124;
INSERT @res SELECT '2. Texto nuevo, embedding obsoleto', ReviewTitle, VECTOR_DISTANCE('cosine', @v, ReviewVector)
FROM dbo.ProductReview WHERE ReviewID = 124;

-- 3. Embedding regenerado para el texto nuevo
UPDATE r
SET r.ReviewVector = AI_GENERATE_EMBEDDINGS(p.Name + ' - ' + r.ReviewTitle + ': ' + r.ReviewText USE MODEL my_embedding_model)
FROM dbo.ProductReview r
INNER JOIN SalesLT.Product p ON r.ProductID = p.ProductID
WHERE r.ReviewID = 124;
INSERT @res SELECT '3. Embedding regenerado', ReviewTitle, VECTOR_DISTANCE('cosine', @v, ReviewVector)
FROM dbo.ProductReview WHERE ReviewID = 124;

-- 4. Restaurar la reseña original y su embedding
UPDATE dbo.ProductReview
SET ReviewTitle = N'Warm hands well below freezing',
    ReviewText = N'Rode through an entire winter with the Full-Finger Gloves and never had cold fingers even at minus 5 degrees with wind chill. The fleece lining is cozy without being bulky and I can still operate my brake levers precisely. Essential cold weather gear.'
WHERE ReviewID = 124;
UPDATE r
SET r.ReviewVector = AI_GENERATE_EMBEDDINGS(p.Name + ' - ' + r.ReviewTitle + ': ' + r.ReviewText USE MODEL my_embedding_model)
FROM dbo.ProductReview r
INNER JOIN SalesLT.Product p ON r.ProductID = p.ProductID
WHERE r.ReviewID = 124;
INSERT @res SELECT '4. Restaurada', ReviewTitle, VECTOR_DISTANCE('cosine', @v, ReviewVector)
FROM dbo.ProductReview WHERE ReviewID = 124;

SELECT * FROM @res;
GO
