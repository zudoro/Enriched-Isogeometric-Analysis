! NAME : HYUNJU KIM
! DATE : 11 / 8 / 2010

MODULE GLBVAR

	USE NEWTYPE

  IMPLICIT NONE

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
!   GLOBAL PARAMETER

	REAL(8), PARAMETER :: PI=DACOS(-1.0D0)
	REAL(8), PARAMETER :: DEGREE = PI/180.D0
	REAL(8), PARAMETER:: EPS=5.0D-15
	INTEGER :: PROBLEM

	! B-SPLINE GLOBAL VARIABLES
	INTEGER, PARAMETER :: NUM_PATCH = 2
	INTEGER :: GEO_ORDER(2), EGM_ORDER(2), BS_ORDER(2), EXTRA_KNOTS(2)
	INTEGER :: GEO_NUMBS(2), NUMBS(NUM_PATCH,2), DOF, LOCAL_DOF(NUM_PATCH), BD_DOF, TEST_NUMBS
	TYPE(BD_INFO) :: BDNDX(NUM_PATCH,MAX_LENGTH)
	LOGICAL, ALLOCATABLE :: BD_MASK(:)
	
	!!  VARIABLES FOR GEOMETRIC MAP
	TYPE(KNOT_VECTOR), SAVE :: GEO_KVEC(NUM_PATCH,2), EGM_KVEC(2), BASIS_KVEC(NUM_PATCH,2)
	TYPE(CONTROL_POINTS_2D) :: GEO_CTL(NUM_PATCH), EGM_CTL

		!!  CONNECTIVITY ARRAY
	INTEGER, ALLOCATABLE :: CARRAY(:,:)
	
	!!  BINOMIAL COEFFICIENTS
	REAL(8) :: BINOM(MAX_DIFF_ORDER,0:MAX_DIFF_ORDER)

	! INTEGRAL GLOBAL VARIABLES
	INTEGER, PARAMETER :: NUMGSPT = 18
	REAL*8 :: IR_GRID(NUM_PATCH, 2, MAX_LENGTH)
	INTEGER :: NUMIR(NUM_PATCH,2)

	REAL*8 :: GSX(NUMGSPT), GSXW(NUMGSPT), GSY(NUMGSPT), GSYW(NUMGSPT)
	INTEGER, ALLOCATABLE :: NDX(:,:)

	CHARACTER(LEN=2) :: CHAR_ORDER(2)
	CHARACTER(LEN=2) :: CHAR_BASIS(2)
	CHARACTER(LEN=5) :: CHAR_KNOT_INTERVAL(2)
	CHARACTER(LEN=2) :: CHAR_SPE_CONST
	CHARACTER(LEN=2) :: CHAR_GEO_CONST
	CHARACTER(LEN=7) :: CHAR_PROBLEM
	CHARACTER(LEN=100) :: FILENAME
	
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!	MATERIAL COEFFICIENTS

	INTEGER, DIMENSION(1:2), PARAMETER :: ORDER1=(/ 1, 2 /)
	INTEGER, DIMENSION(1:2), PARAMETER :: ORDER2=(/ 2, 1 /)

	TYPE(POINT2D), PARAMETER :: PT0 = POINT2D(0.D0,0.D0)

END MODULE GLBVAR
