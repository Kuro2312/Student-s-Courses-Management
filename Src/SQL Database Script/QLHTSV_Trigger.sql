USE StudentCoursesManagement
GO
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
UPDATE	dbo.DANGKY 
SET		NAM = (SELECT	NAM
			   FROM		dbo.KETQUA KQ
			   WHERE	KQ.MASV = MASV);			   
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--R1
--LOAI PHAI TUONG XUNG VOI DTB
--BẢNG TẦM ẢNH HƯỞNG: KETQUA: I(+), D(-), U(+(DIEMTB, XEPLOAI))
IF OBJECT_ID('UTR_RB1', 'TR') IS NOT NULL
	DROP TRIGGER UTR_RB1
GO
CREATE TRIGGER UTR_RB1
ON KETQUA
FOR INSERT, UPDATE
AS BEGIN
	--ĐIỂM TRUNG BÌNH THAY ĐỔI THÌ PHẢI SỬA LẠI XẾP LOẠI
	DECLARE @MASV INT, @NAM INT
	SET @MASV = (SELECT MASV FROM INSERTED)
	SET @NAM = (SELECT NAM FROM INSERTED)
	IF UPDATE(DIEMTB)
	BEGIN
		DECLARE @DIEMTB REAL		
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
		IF (@DIEMTB > 9)
		BEGIN
			UPDATE	dbo.KETQUA
			SET		XEPLOAI = 'XS'
			WHERE	MASV = @MASV AND NAM = @NAM
		END
	END
	--THAY ĐỔI XẾP LOẠI THÌ PHẢI KIỂM TRA ĐIỂM TRUNG BÌNH
	IF UPDATE(XEPLOAI)
	BEGIN
		DECLARE @DIEMTB1 REAL, @XEPLOAI CHAR(5)
		SET @DIEMTB1 = (SELECT		DIEMTB
						FROM		dbo.KETQUA
						WHERE		MASV = @MASV AND NAM = @NAM)
		SET @XEPLOAI = (SELECT XEPLOAI FROM Inserted)
		IF ((@DIEMTB1 < 6.5 AND @XEPLOAI <> 'KHA') OR 
			(@DIEMTB1 >= 6.5 AND @DIEMTB1 < 9 AND @XEPLOAI <> 'GIOI') OR 
			(@DIEMTB1 >= 9 AND @XEPLOAI <> 'XS'))
		BEGIN
			RAISERROR('RB1: ERROR',16,1)
			ROLLBACK
		END
	END
END
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
--R2
--DTB BANG TONG DIEM CHIA TONG MON
--NẾU UPDATE ĐIỂM Ở ĐĂNG KÍ THÌ CẬP NHẬT LẠI ĐIỂM TRUNG BINGH
--BẢNG TẦM ẢNH HƯỜNG: DANGKY: I(+), D(+), U(+(DIEM))
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
--R3
--KHÔNG CHO ĐĂNG KÍ QUÁ 8 MÔN
--BẢNG TẦM ẢNH HƯỞNG: DANGKY: I(+), D(-), U(-)
IF OBJECT_ID('UTR_RB3', 'TR') IS NOT NULL
	DROP TRIGGER UTR_RB3
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
CREATE TRIGGER UTR_RB3
ON DANGKY
FOR INSERT, UPDATE
AS BEGIN
	IF ((SELECT		COUNT(*)
		 FROM		Inserted) <> 0)
	BEGIN
	    DECLARE @MASV INT, @MAMH CHAR(5), @NAM INT, @HOCKY INT
		SET @MASV = (SELECT MASV FROM Inserted)
		SET @MAMH = (SELECT MAMH FROM Inserted)
		SET @NAM = (SELECT NAM FROM Inserted)
		SET @HOCKY = (SELECT HOCKY FROM Inserted)
		IF ((SELECT		COUNT(*)
			 FROM		dbo.DANGKY
			 WHERE		MASV = @MASV AND @MAMH = MAMH AND 
						@NAM = NAM AND HOCKY = @HOCKY) >= 8)
		BEGIN
			RAISERROR('RB1: ERROR',16,1)
			ROLLBACK
		END
	END     
END
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
