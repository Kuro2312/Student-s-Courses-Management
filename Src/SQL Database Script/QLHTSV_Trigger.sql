USE StudentCoursesManagement
GO
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
UPDATE	dbo.DANGKY 
SET		NAM = (SELECT	NAM
			   FROM		dbo.KETQUA KQ
			   WHERE	KQ.MASV = MASV)
			   
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--R1
--LOAI PHAI TUONG XUNG VOI DTB
IF OBJECT_ID('UTR_RB1', 'TR') IS NOT NULL
	DROP TRIGGER UTR_RB1
GO
CREATE TRIGGER UTR_RB1
ON KETQUA
FOR INSERT, UPDATE
AS BEGIN
	IF UPDATE(DIEMTB)
	BEGIN
		DECLARE @MASV INT, @NAM INT, @DIEMTB REAL
		SET @MASV = (SELECT MASV FROM INSERTED)
		SET @NAM = (SELECT NAM FROM INSERTED)
		SET @DIEMTB = (SELECT DIEMTB FROM INSERTED)

		IF (@DIEMTB < 6.5)
		BEGIN
			UPDATE	dbo.KETQUA
			SET		XEPLOAI = 'KHA'
			WHERE	MASV = @MASV AND NAM = @NAM
		END

		IF (@DIEMTB >= 6.5 AND @DIEMTB < 9)
		BEGIN
			UPDATE	dbo.KETQUA
			SET		XEPLOAI = 'GIOI'
			WHERE	MASV = @MASV AND NAM = @NAM
		END	
		
		IF (@DIEMTB >= 9)
		BEGIN
			UPDATE	dbo.KETQUA
			SET		XEPLOAI = 'XUATSAC'
			WHERE	MASV = @MASV AND NAM = @NAM
		END		
	END
END
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--R2
--DTB BANG TONG DIEM CHIA TONG MON
IF OBJECT_ID('UTR_RB2', 'TR') IS NOT NULL
	DROP TRIGGER UTR_RB2
GO
CREATE TRIGGER UTR_RB2
ON DANGKY
FOR INSERT, UPDATE, DELETE
AS BEGIN
	IF UPDATE(DIEM)
	BEGIN
	    DECLARE @MASV INT, @NAM INT, @TONGMON INT, @TONGDIEM INT, @DIEMTB REAL
		SET @MASV = (SELECT MASV FROM INSERTED)
		SET @NAM = (SELECT NAM FROM INSERTED)

		SET @TONGMON = (SELECT	COUNT(*)
						FROM	dbo.DANGKY
						WHERE	MASV = @MASV AND
								NAM = @NAM)
		SET @TONGDIEM = (SELECT		SUM(DIEM)
						 FROM		dbo.DANGKY
						 WHERE		MASV = @MASV AND
									NAM = @NAM)
		SET @DIEMTB = @TONGDIEM / @TONGMON

		UPDATE	dbo.KETQUA
		SET		DIEMTB = @DIEMTB
		WHERE	MASV = @MASV AND
				NAM = @NAM
	END
END
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--SP1 TINH DIEM TRUNG BINH
IF OBJECT_ID('TINHDIEMTB','P') IS NOT NULL
	DROP PROC TINHDIEMTB
GO
CREATE PROCEDURE TINHDIEMTB @MASV INT, @NAM INT
AS BEGIN
	DECLARE @TONGMON INT, @TONGDIEM INT, @DTB REAL
	
	SET @TONGMON = (SELECT	COUNT(*)
					FROM	dbo.DANGKY
					WHERE	MASV = @MASV AND
							NAM = @NAM)
	SET @TONGDIEM = (SELECT		SUM(DIEM)
					 FROM		dbo.DANGKY
					 WHERE		MASV = @MASV AND
								NAM = @NAM)
	SET @DTB = @TONGDIEM / @TONGMON

END
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--SP2 XEPLOAI
IF OBJECT_ID('XEPLOAI','P') IS NOT NULL
	DROP PROC XEPLOAI
GO
CREATE PROCEDURE XEPLOAI @MASV INT, @DTB REAL
AS BEGIN
	
END
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------