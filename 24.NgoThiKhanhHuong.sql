--1. Tạo cơ sở dữ liệu SinhVien gồm các bảng sau:

    --SinhVien(MaSV, TenSV, NgaySinh, GioiTinh, Lop)

    --Diem(MaMonHoc, MaSV, Diem)


create database SINHVIEN
GO
create table sinhvien
(
	 MaSV  char(5),
	 TenSV nvarchar(50),
	 NgaySinh date,
	 GioiTinh nvarchar(10),
	 Lop varchar(10),
 primary key (MaSV)
)
GO
create table diem
(
	MaMonHoc char(6),
	MaSV char(5),
	Diem int,
primary key (MaMonHoc),
foreign key (MaSV) references sinhvien
)

--2. Thêm mới mỗi bảng 2-3 dòng dữ liệu
insert into sinhvien values ('00001', N'Nguyễn Văn A', '02/02/1999', N'Nam', '43K21')
insert into sinhvien values ('00002', N'Nguyễn Thị B', '04/04/1999', N'Nữ', '43K21')

insert into diem values ('100001', '00001', 9)
insert into diem values ('100002', '00002', 8)

select * from sinhvien
select * from diem


--3. Viết hàm trả về tên nếu biết mã sinh viên

create function cau3 (@MaSV char(5))
returns nvarchar(50)
as
begin
	declare @TenSV nvarchar(50)
	select @TenSV = TenSV
	from sinhvien
	where MaSV = @MaSV
	return @TenSV
end

--test 
select dbo.cau3 ('00001')



--4. Viết hàm trả về số lượng sinh viên đã tham gia môn học nếu biết mã môn học

create function cau4 (@MaMH char(6))
returns int
as
begin
	declare @SL int
	select @SL = count(diem.MaSV)
	from diem 
	where MaMonHoc = @MaMH
	return @SL
end

--test
select dbo.cau3 ('100001')

--5. Viết thủ tục thêm mới dữ liệu vào bảng Diem như mô tả dưới đây:

--Input: MaMonHoc, MaSV, Diem

--Output: 0 nếu bị lỗi, 1 nếu thành công

	create proc cau5 @MaMH char(6),
					 @MaSV char(5),
					 @diem int,
					 @ret int out
	BEGIN
--Các bước thực hiện:

--B1. Kiểm tra Diem có hợp lệ không (hợp lệ: 0 < Diem <= 10). Nếu không hợp lệ, kết thúc thủ tục và trả về giá trị 0

if ('0' < @diem) and (@diem <= '10')
begin
		print 'looxi'
		set @ret = 0
		return
end	

--B2: Kiểm tra MaSV đã tồn tại trong bảng SinhVien chưa. Nếu chưa tồn tại, kết thúc thủ tục và trả về giá trị 0.
declare @count int = 0
select @count = count(*) from diem where MaSV = @MaSV
if @count < 0
begin 
	set @ret = 0
	print 'loi'
	return 
end

--Bước 3. Thêm mới dữ liệu với các giá trị input

insert into Diem values (@MaMH, @MaSV, @Diem)

--Bước 4. Nếu thêm mới thành công thì trả về 1, ngược lại trả về 0.

	IF @@ROWCOUNT > 0
		SET @ret = '1'
	ELSE
		SET @ret = '0'
END

--test
declare  @c int out
exec dbo.cau5 '100009', '10006', 7, @c out
print @c




--6. Khi thêm mới dữ liệu vào bảng Sinvien hãy đảm bảo rằng NgaySinh không phải là ngày hiện tại.

create trigger cau6
on sinhvien
for insert
as
begin
	declare @NgaySinh date
	select @NgaySinh = NgaySinh
	from sinhvien
	where not exists ( select NgaySinh
						from inserted
						where @ngaysinh = getdate()
						)
end

--test
insert into sinhvien(MaMH, MaSV, diem) values('100003', '10005', 8)
