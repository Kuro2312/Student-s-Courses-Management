USE StudentCoursesManagement;

---------------------------------------------------------------------------------------------------
-- Trasaction: Get All Opened Courses
IF OBJECT_ID('sp_GetAllOpenedCourses', 'P') is not null
	DROP PROC sp_GetAllOpenedCourses
GO
CREATE PROC sp_GetAllOpenedCourses 
	@year INT, 
	@semester INT
AS 
BEGIN

	-- Kiểm tra điều kiện
	DECLARE @currentYear INT;
	SELECT @currentYear = YEAR(GETDATE());
	
	IF (@year < 1990 OR @currentYear >= @year OR @semester < 1 OR @semester > 2)
	BEGIN 
		RETURN 0;
	END;
	
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL SERIALIZABLE
		SELECT * 
		FROM DANGKY AS DK JOIN MONHOC AS MH
		ON (DK.MAMH = MH.MAMH AND DK.NAM = @year AND DK.HOCKY = @semester) 	
	COMMIT TRAN
	
	RETURN 1;
	
END;
---------------------------------------------------------------------------------------------------
-- Trasaction: Register a Course
IF OBJECT_ID('sp_RegisterCourse', 'P') is not null
	DROP PROC sp_RegisterCourse
GO
CREATE PROC sp_RegisterCourse 
	@studentID CHAR(5),
	@objectID CHAR(5),
	@year INT, 
	@semester INT
AS 
BEGIN

	-- Kiểm tra điều kiện
	DECLARE @currentYear INT;
	SELECT @currentYear = YEAR(GETDATE());
	
	IF (@year < 1990 OR @currentYear >= @year OR @semester < 1 OR @semester > 2
			OR @objectID IS NULL OR @studentID IS NULL)
	BEGIN 
		RETURN 0;
	END;
	
	-- Kiểm tra mã sinh viên có tồn tại
	IF (NOT EXISTS (SELECT MAMH 
				FROM MHMO 
				WHERE (MAMH = @objectID AND NAM = @year AND HOCKY = @semester)))
	BEGIN 
		RETURN 0;
	END;
	
	-- Kiểm tra mã sinh viên có tồn tại
	IF (NOT EXISTS (SELECT MASV 
				FROM SINHVIEN 
				WHERE (MASV = @studentID)))
	BEGIN 
		RETURN 0;
	END;
	
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL	SERIALIZABLE
		-- Kiểm tra còn chỗ
		IF ((SELECT DISTINCT COUNT * FROM DANGKI 
				WHERE (MAMH = @objectID AND NAM = @year AND HOCKY = @semester)) <
				(SELECT SOCHOMAX FROM MONHOC WHERE MAMH = @objectID))	
		BEGIN
			INSERT INTO DANGKY	(MASV, MAMH, NAM, HOCKY, DIEM)
			VALUES (@studentID, @objectID, @year, @semester, NULL);
		END;
	COMMIT TRAN
	
	RETURN 1;
	
END;
---------------------------------------------------------------------------------------------------
-- Trasaction: Cancel a Course
IF OBJECT_ID('sp_CancelCourse', 'P') is not null
	DROP PROC sp_CancelCourse
GO
CREATE PROC sp_CancelCourse 
	@studentID CHAR(5),
	@objectID CHAR(5),
	@year INT, 
	@semester INT
AS 
BEGIN

	-- Kiểm tra điều kiện
	DECLARE @currentYear INT;
	SELECT @currentYear = YEAR(GETDATE());
	
	IF (@year < 1990 OR @currentYear >= @year OR @semester < 1 OR @semester > 2
			OR @objectID IS NULL OR @studentID IS NULL)
	BEGIN 
		RETURN 0;
	END;
	
	-- Kiểm tra mã sinh viên có tồn tại
	IF (NOT EXISTS (SELECT MAMH 
				FROM MHMO 
				WHERE (MAMH = @objectID AND NAM = @year AND HOCKY = @semester)))
	BEGIN 
		RETURN 0;
	END;
	
	-- Kiểm tra mã sinh viên có tồn tại
	IF (NOT EXISTS (SELECT MASV 
				FROM SINHVIEN 
				WHERE (MASV = @studentID)))
	BEGIN 
		RETURN 0;
	END;
	
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL	READ COMMITTED
		DELETE FROM DANGKY
		WHERE (MASV = @studentID AND MAMH = @objectID AND NAM = @year AND HOCKY = @semester);
	COMMIT TRAN
	
	RETURN 1;
	
END;
---------------------------------------------------------------------------------------------------
-- Trasaction: Open a Course
IF OBJECT_ID('sp_OpenCourse', 'P') is not null
	DROP PROC sp_OpenCourse
GO
CREATE PROC sp_OpenCourse 
	@objectID CHAR(5),
	@year INT, 
	@semester INT
AS 
BEGIN

	-- Kiểm tra điều kiện
	DECLARE @currentYear INT;
	SELECT @currentYear = YEAR(GETDATE());
	
	IF (@year < 1990 OR @currentYear >= @year OR @semester < 1 OR @semester > 2
			OR @objectID IS NULL)
	BEGIN 
		RETURN 0;
	END;
	
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL	READ COMMITTED
		-- Kiểm tra mã khóa học có tồn tại
		IF (NOT EXISTS (SELECT MAMH 
				FROM MHMO 
				WHERE (MAMH = @objectID AND NAM = @year AND HOCKY = @semester)))
		BEGIN
			INSERT INTO MHMO (MAMH, NAM, HOCKY)
			VALUES (@objectID, @year, @semester);
		END;
	COMMIT TRAN
	
	RETURN 1;
	
END;
---------------------------------------------------------------------------------------------------
-- Trasaction: Update Max Number Of  Students Of Course
IF OBJECT_ID('sp_UpdateMaxStudentsOfCourse', 'P') is not null
	DROP PROC sp_UpdateMaxStudentsOfCourse
GO
CREATE PROC sp_UpdateMaxStudentsOfCourse 
	@objectID CHAR(5),
	@number INT
AS 
BEGIN

	-- Kiểm tra điều kiện
	IF (@number <= 0 OR @objectID IS NULL)
	BEGIN 
		RETURN 0;
	END;
	
	BEGIN TRAN
	SET TRANSACTION ISOLATION LEVEL	READ COMMITTED
		UPDATE MONHOC 
		SET SOCHOMAX = SOCHOMAX + @number
		WHERE MAMH = @objectID;
	COMMIT TRAN
	
	RETURN 1;
	
END;
---------------------------------------------------------------------------------------------------
--Transaction: Get Result of Student
IF OBJECT_ID('sp_GetResultofStudent', 'P') IS NOT NULL
	DROP PROC sp_GetResultofStudent
GO
CREATE PROC sp_GetResultofStudent @MASV INT
AS BEGIN
	--Kiểm tra điều kiện
	IF (@MASV NOT IN (SELECT	MASV
					  FROM		dbo.SINHVIEN))
		RETURN 0;
	BEGIN TRAN
	SET TRAN ISOLATION LEVEL READ COMMITTED
		SELECT	*
		FROM	dbo.DANGKY 
		WHERE	MASV = @MASV
	COMMIT TRAN
	RETURN 1;
END;
---------------------------------------------------------------------------------------------------
--Transaction: Update Result of Student
IF OBJECT_ID('sp_UpdateResultofStudent', 'P') IS NOT NULL
	DROP PROC sp_UpdateResultofStudent
GO
CREATE PROC sp_UpdateResultofStudent @MASV INT, @DIEM REAL
AS BEGIN
	--Kiểm tra điều kiện
	IF (@MASV NOT IN (SELECT	MASV
					  FROM		dbo.SINHVIEN) OR 
					  (0 <= @DIEM AND @DIEM <= 10))
		RETURN 0;
	BEGIN TRAN
	SET TRAN ISOLATION LEVEL READ COMMITTED
		UPDATE	dbo.DANGKY
		SET		DIEM = @DIEM
		WHERE	MASV = @MASV
	COMMIT TRAN
	RETURN 1;
END;
---------------------------------------------------------------------------------------------------
--Transaction: Get Result of Student in a Year
IF OBJECT_ID('sp_GetResultofStudentInYear', 'P') IS NOT NULL
	DROP PROC sp_GetResultofStudentInYear
GO
CREATE PROC sp_GetResultofStudentInYear @MASV INT
AS BEGIN
	--Kiểm tra điều kiện
	IF (@MASV NOT IN (SELECT	MASV
					  FROM		dbo.SINHVIEN))
		RETURN 0;
	BEGIN TRAN
	SET TRAN ISOLATION LEVEL READ COMMITTED
		SELECT	*
		FROM	dbo.KETQUA
		WHERE	MASV = @MASV
	COMMIT TRAN
	RETURN 1;
END;
---------------------------------------------------------------------------------------------------
--Transaction: Get All Students
IF OBJECT_ID('sp_GetAllStudents', 'P') is not null
	DROP PROC sp_GetAllStudents
GO
CREATE PROC sp_GetAllStudents
AS BEGIN
	BEGIN TRAN
	SET TRAN ISOLATION LEVEL SERIALIZABLE
		SELECT	*
		FROM	dbo.SINHVIEN
	COMMIT TRAN
END;
---------------------------------------------------------------------------------------------------
--Transaction: Add New Student
IF OBJECT_ID('sp_AddNewStudent', 'P') IS NOT NULL
	DROP PROC sp_AddNewStudent
GO
CREATE PROC sp_AddNewStudent @MASV INT, @HOTEN NVARCHAR(50), @NGSINH DATETIME, @MALOP CHAR(6)
AS BEGIN
	--Kiểm tra điều kiện
	IF ((@MASV IS NULL) OR (@MALOP NOT IN (SELECT	MALOP
										   FROM		dbo.LOP)))
		RETURN 0;
	BEGIN TRAN
	SET TRAN ISOLATION LEVEL SERIALIZABLE
		INSERT dbo.SINHVIEN VALUES(@MASV, @HOTEN, @NGSINH, @MALOP)
		UPDATE	dbo.LOP
		SET		SISO = SISO + 1
		WHERE	MALOP = @MALOP
	COMMIT TRAN

	RETURN 1;
END;
---------------------------------------------------------------------------------------------------
--Transaction: Update Date of Birth for Student
IF OBJECT_ID('sp_UpdateDoB', 'P') IS NOT NULL
	DROP PROC sp_UpdateDoB
GO
CREATE PROC sp_UpdateDoB @MASV INT, @NgSinh DATETIME
AS BEGIN
	--Kiểm tra điều kiện
	IF (@MASV NOT IN (SELECT	MASV
					  FROM		dbo.SINHVIEN))
		RETURN 0;
	BEGIN TRAN
	SET TRAN ISOLATION LEVEL READ COMMITTED
		UPDATE	dbo.SINHVIEN
		SET		NGAYSINH = @NgSinh
		WHERE	MASV = @MASV
	COMMIT TRAN

	RETURN 1;
END;
---------------------------------------------------------------------------------------------------
--Transaction: Move class for Student
IF OBJECT_ID('sp_ChangeClass', 'P') IS NOT NULL
	DROP PROC sp_ChangeClass
GO
CREATE PROC sp_ChangeClass @MASV INT, @MALOP_MOI CHAR(6)
AS BEGIN
	--Kiểm tra điều kiện
	IF ((@MASV NOT IN (SELECT	MASV
					   FROM		dbo.SINHVIEN)) OR 
					   (@MALOP_MOI NOT IN (SELECT	MALOP
										   FROM		dbo.LOP)))
		RETURN 0;

	BEGIN TRAN
	SET TRAN ISOLATION LEVEL READ COMMITTED
		DECLARE @MALOP_CU CHAR(6)

		SET @MALOP_CU = (SELECT MALOP FROM dbo.SINHVIEN WHERE MASV = @MASV)
		UPDATE	dbo.SINHVIEN
		SET		MALOP = @MALOP_MOI
		WHERE	MASV = @MASV

		UPDATE	dbo.LOP
		SET		SISO = SISO + 1
		WHERE	MALOP = @MALOP_MOI

		UPDATE	dbo.LOP
		SET		SISO = SISO - 1
		WHERE	MALOP = @MALOP_CU
	COMMIT TRAN
	RETURN 1;
END;