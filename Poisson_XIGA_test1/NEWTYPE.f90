 MODULE NEWTYPE

    IMPLICIT NONE
    
  real(8), parameter :: Tolerance = 5.0d-16
	integer, parameter :: Max_Iteration = 20
	integer, parameter :: Max_Length = 100, Max_Order = 50, Max_Diff_Order = 2
	
	TYPE FVALUE
		REAL(8) :: D00,D10,D01,D20,D02,D11
	END TYPE FVALUE

	! 2D POINT
	TYPE POINT2D
		REAL(8) :: X,Y
	END TYPE POINT2D

	! 2D VECTOR
	TYPE VEC2D
		TYPE(POINT2D) :: U,V
	END TYPE VEC2D

	! 2D INTEGER VECTOR
	TYPE INT2D
		INTEGER :: A, B
	END TYPE INT2D

	! 3D INTEGER VECTOR
	TYPE INT3D
		INTEGER :: A,B,C
	END TYPE INT3D

	! RECTANGULAR PATCH 2D
	TYPE RECPATCH
		TYPE(POINT2D) :: PT1,PT2,PT3,PT4
	END TYPE RECPATCH

	! TRIANGULAR PATCH 2D
	TYPE TRIPATCH
		TYPE(POINT2D) :: PT1, PT2, PT3
	END TYPE TRIPATCH

	TYPE TRANSFORM2D
		TYPE(POINT2D) :: PT
		REAL(8) :: JACOBIAN, DXDX, DXDY, DYDX, DYDY
	END TYPE TRANSFORM2D

	TYPE INTPATCH
		TYPE(RECPATCH) :: SUBPATCH
		INTEGER :: SUBINDEX, PATCHNUMBER
	END TYPE INTPATCH

	TYPE DISPLACEMENT
		REAL*8 :: W0, PIX, PIY
	END TYPE DISPLACEMENT

	TYPE MOMENT
		REAL*8 :: MXX, MYY, MXY
	END TYPE MOMENT

	TYPE STRESS
		REAL*8 :: SXX, SYY, SXY, SYZ, SXZ
	END TYPE STRESS

	!! 2X2 MATRIX
	TYPE MATRIX_22
		REAL(8) :: ENT(2,2)
	END TYPE MATRIX_22

	!!  FUNCTION ON ONE-DIMENSIONAL SPACE
	TYPE FUNCTION_1D
		REAL(8) :: VAL(0:MAX_DIFF_ORDER)
	END TYPE FUNCTION_1D

	!!  FUNCTION ON TWO-DIMENSIONAL SPACE
	TYPE FUNCTION_2D
		REAL(8) :: VAL(0:MAX_DIFF_ORDER,0:MAX_DIFF_ORDER)
	END TYPE FUNCTION_2D

	!!  SECOND-ORDER PARTIAL DERIVATIVES
	TYPE SECOND_PARTIAL_DERIVATIVES
		REAL(8) :: X(3) = (/ 0.0D0, 0.0D0, 0.0D0 /), Y(3) = (/ 0.0D0, 0.0D0, 0.0D0 /)
	END TYPE SECOND_PARTIAL_DERIVATIVES
	
	!!  ONE-DIMENSIONAL KNOT-VECTORS
	TYPE KNOT_VECTOR
		INTEGER :: LENGTH = -1, POLY_ORDER = -1
		REAL(8) :: KNOTS(0:MAX_LENGTH)
	END TYPE KNOT_VECTOR
	
	!!  BSPLINE FUNCTIONS
	TYPE BSPLINES
		INTEGER :: INIT = -1, POLY_ORDER = -1
		REAL(8) :: N(0:MAX_ORDER)
	END TYPE BSPLINES

	!!  BSPLINE FUNCTIONS AND THEIR DERIVATIVES
	TYPE DIFF_BSPLINES
		INTEGER :: INIT = -1, POLY_ORDER = -1, DIFF_ORDER = -1
		REAL(8) :: N(0:MAX_ORDER,0:MAX_DIFF_ORDER)
	END TYPE DIFF_BSPLINES

	!!  CONTROL POINTS AND WEIGHTS
	TYPE CONTROL_POINTS_2D
		INTEGER :: D = 0
		TYPE(POINT2D) :: PTS(0:MAX_ORDER,0:MAX_ORDER,0:MAX_ORDER)
		REAL(8) :: WGTS(0:MAX_ORDER,0:MAX_ORDER,0:MAX_ORDER)
	END TYPE CONTROL_POINTS_2D

	TYPE BD_INFO
		INTEGER :: LC_NDX(1:2) ! LOCAL INDEX
		INTEGER :: GL_NDX ! GLOBAL INDEX
		INTEGER :: LC_NUM
	END TYPE BD_INFO

  ! NEW OPERATION ON THE NEW TYPE
  INTERFACE OPERATOR(+)
  MODULE PROCEDURE EXT_PATCH
  MODULE PROCEDURE ADD_POINT2D
  MODULE PROCEDURE EXT_VEC2D
	MODULE PROCEDURE ADD_FVALUE
	MODULE PROCEDURE ADD_FUNCTION_1D
	MODULE PROCEDURE ADD_FUNCTION_2D
	MODULE PROCEDURE ADD_DISP
  END INTERFACE

	INTERFACE OPERATOR(-)
	MODULE PROCEDURE SUBTRACT_PT2D
	MODULE PROCEDURE SUBTRACT_FUNCTION_1D
	MODULE PROCEDURE SUBTRACT_FUNCTION_2D
	END INTERFACE
	
	INTERFACE OPERATOR (*)
		MODULE PROCEDURE SCALAR_PRODUCT_POINT2D, INNER_PRODUCT_POINT2D
		MODULE PROCEDURE SCALAR_PRODUCT_FUNCTION_1D, PRODUCT_FUNCTION_1D
		MODULE PROCEDURE SCALAR_PRODUCT_FUNCTION_2D
		MODULE PROCEDURE SCALAR_PRODUCT_FVALUE
	END INTERFACE
	
	INTERFACE OPERATOR(.AND.)
	MODULE PROCEDURE RECPATCH_INTERSECTION
	END INTERFACE

	INTERFACE OPERATOR(.IN.)
		MODULE PROCEDURE BELONGTO_R
		MODULE PROCEDURE LIEON
		MODULE PROCEDURE PTLIEON
		MODULE PROCEDURE REC_BELONGTO_REC
	END INTERFACE

	INTERFACE OPERATOR (.DETERMINANT.)
		MODULE PROCEDURE DETERMINANT_MATRIX_22
	END INTERFACE

	INTERFACE OPERATOR (.INVERSE.)
		MODULE PROCEDURE INVERSE_MATRIX_22
	END INTERFACE

	INTERFACE OPERATOR (.TRANSPOSE.)
		MODULE PROCEDURE TRANSPOSE_MATRIX_22
	END INTERFACE
	
CONTAINS

!!!!! FUNCTIONS FOR THE NEW OPERATION + !!!!!

TYPE(DISPLACEMENT) FUNCTION ADD_DISP(DISP1, DISP2)
	TYPE(DISPLACEMENT), INTENT(IN) :: DISP1, DISP2
	
	ADD_DISP%W0 = DISP1%W0 + DISP2%W0
	ADD_DISP%PIX = DISP1%PIX + DISP2%PIX
	ADD_DISP%PIY = DISP1%PIY + DISP2%PIY

END FUNCTION ADD_DISP

	TYPE(POINT2D) FUNCTION SUBTRACT_POINT2D(PT1,PT2)

		TYPE(POINT2D), INTENT(IN) :: PT1, PT2

		SUBTRACT_POINT2D = POINT2D(PT1%X-PT2%X,PT1%Y-PT2%Y)

	END FUNCTION SUBTRACT_POINT2D

	!!  SCALAR PRODUCT
	TYPE(POINT2D) FUNCTION SCALAR_PRODUCT_POINT2D(SCALAR,PT)

		REAL(8), INTENT(IN) :: SCALAR
		TYPE(POINT2D), INTENT(IN) :: PT

		SCALAR_PRODUCT_POINT2D = POINT2D(SCALAR*PT%X,SCALAR*PT%Y)

	END FUNCTION SCALAR_PRODUCT_POINT2D

	!!  INNER PRODUCT
	REAL(8) FUNCTION INNER_PRODUCT_POINT2D(PT1,PT2)

		TYPE(POINT2D), INTENT(IN) :: PT1, PT2

		INNER_PRODUCT_POINT2D = PT1%X*PT2%X + PT1%Y*PT2%Y

	END FUNCTION INNER_PRODUCT_POINT2D


	!!  OPERATIONS OF FUNCTION_1D

	!!  ADDITION
	TYPE(FUNCTION_1D) FUNCTION ADD_FUNCTION_1D(FUN1,FUN2)

		TYPE(FUNCTION_1D), INTENT(IN) :: FUN1, FUN2
		INTEGER :: K

		DO K = 0, MAX_DIFF_ORDER
			ADD_FUNCTION_1D%VAL(K) = FUN1%VAL(K) + FUN2%VAL(K)
		ENDDO

	END FUNCTION ADD_FUNCTION_1D

	!!  SUBTRACTION
	TYPE(FUNCTION_1D) FUNCTION SUBTRACT_FUNCTION_1D(FUN1,FUN2)

		TYPE(FUNCTION_1D), INTENT(IN) :: FUN1, FUN2
		INTEGER :: K

		DO K = 0, MAX_DIFF_ORDER
			SUBTRACT_FUNCTION_1D%VAL(K) = FUN1%VAL(K) - FUN2%VAL(K)
		ENDDO

	END FUNCTION SUBTRACT_FUNCTION_1D

	!!  SCALAR PRODUCT
	TYPE(FUNCTION_1D) FUNCTION SCALAR_PRODUCT_FUNCTION_1D(SCALAR,FUN)

		REAL(8), INTENT(IN) :: SCALAR
		TYPE(FUNCTION_1D), INTENT(IN) :: FUN
		INTEGER :: K

		DO K = 0, MAX_DIFF_ORDER
			SCALAR_PRODUCT_FUNCTION_1D%VAL(K) = SCALAR * FUN%VAL(K)
		ENDDO

	END FUNCTION SCALAR_PRODUCT_FUNCTION_1D

	!!  PRODUCT
	TYPE(FUNCTION_1D) FUNCTION PRODUCT_FUNCTION_1D(FUN1,FUN2)

		TYPE(FUNCTION_1D), INTENT(IN) :: FUN1, FUN2

		PRODUCT_FUNCTION_1D%VAL(0) = FUN1%VAL(0)*FUN2%VAL(0)
		PRODUCT_FUNCTION_1D%VAL(1) = FUN1%VAL(1)*FUN2%VAL(0) + FUN1%VAL(0)*FUN2%VAL(1)
		PRODUCT_FUNCTION_1D%VAL(2) = FUN1%VAL(2)*FUN2%VAL(0) + 2.0D0*FUN1%VAL(1)*FUN2%VAL(1) + FUN1%VAL(0)*FUN2%VAL(2)

	END FUNCTION PRODUCT_FUNCTION_1D

	!!  ADDITION
	TYPE(FUNCTION_2D) FUNCTION ADD_FUNCTION_2D(FUN1,FUN2)

		TYPE(FUNCTION_2D), INTENT(IN) :: FUN1, FUN2
		INTEGER :: K, L

		DO K = 0, MAX_DIFF_ORDER
		DO L = 0, MAX_DIFF_ORDER
			ADD_FUNCTION_2D%VAL(K,L) = FUN1%VAL(K,L) + FUN2%VAL(K,L)
		ENDDO
		ENDDO

	END FUNCTION ADD_FUNCTION_2D

	!!  SUBTRACTION
	TYPE(FUNCTION_2D) FUNCTION SUBTRACT_FUNCTION_2D(FUN1,FUN2)

		TYPE(FUNCTION_2D), INTENT(IN) :: FUN1, FUN2
		INTEGER :: K, L

		DO K = 0, MAX_DIFF_ORDER
		DO L = 0, MAX_DIFF_ORDER
			SUBTRACT_FUNCTION_2D%VAL(K,L) = FUN1%VAL(K,L) - FUN2%VAL(K,L)
		ENDDO
		ENDDO

	END FUNCTION SUBTRACT_FUNCTION_2D

	!!  SCALAR PRODUCT
	TYPE(FUNCTION_2D) FUNCTION SCALAR_PRODUCT_FUNCTION_2D(SCALAR,FUN)

		REAL(8), INTENT(IN) :: SCALAR
		TYPE(FUNCTION_2D), INTENT(IN) :: FUN
		INTEGER :: K, L

		DO K = 0, MAX_DIFF_ORDER
		DO L = 0, MAX_DIFF_ORDER
			SCALAR_PRODUCT_FUNCTION_2D%VAL(K,L) = SCALAR * FUN%VAL(K,L)
		ENDDO
		ENDDO

	END FUNCTION SCALAR_PRODUCT_FUNCTION_2D
	
TYPE(FVALUE) FUNCTION SCALAR_PRODUCT_FVALUE(SCALAR,FUN)
	REAL*8, INTENT(IN) :: SCALAR
	TYPE(FVALUE), INTENT(IN) :: FUN
	
	SCALAR_PRODUCT_FVALUE%D00 = SCALAR*FUN%D00
	SCALAR_PRODUCT_FVALUE%D10 = SCALAR*FUN%D10
	SCALAR_PRODUCT_FVALUE%D01 = SCALAR*FUN%D01
	SCALAR_PRODUCT_FVALUE%D11 = SCALAR*FUN%D11
	SCALAR_PRODUCT_FVALUE%D20 = SCALAR*FUN%D20
	SCALAR_PRODUCT_FVALUE%D02 = SCALAR*FUN%D02
	
END FUNCTION SCALAR_PRODUCT_FVALUE

	TYPE(RECPATCH) FUNCTION EXT_PATCH(OLDPATCH,AMOUNT)
		TYPE(RECPATCH), INTENT(IN) :: OLDPATCH
		REAL*8, INTENT(IN) :: AMOUNT

		EXT_PATCH%PT1=POINT2D(OLDPATCH%PT1%X-AMOUNT,OLDPATCH%PT1%Y-AMOUNT)
		EXT_PATCH%PT2=POINT2D(OLDPATCH%PT2%X+AMOUNT,OLDPATCH%PT2%Y-AMOUNT)
		EXT_PATCH%PT3=POINT2D(OLDPATCH%PT3%X+AMOUNT,OLDPATCH%PT3%Y+AMOUNT)
		EXT_PATCH%PT4=POINT2D(OLDPATCH%PT4%X-AMOUNT,OLDPATCH%PT4%Y+AMOUNT)
		
	END FUNCTION EXT_PATCH

        TYPE(VEC2D) FUNCTION EXT_VEC2D(INVEC,AMOUNT)
            TYPE(VEC2D),INTENT(IN) :: INVEC
            REAL(8), INTENT(IN) :: AMOUNT
            EXT_VEC2D%U%X=INVEC%U%X-AMOUNT
            EXT_VEC2D%U%Y=INVEC%U%Y-AMOUNT
            EXT_VEC2D%V%X=INVEC%V%X+AMOUNT
            EXT_VEC2D%V%Y=INVEC%V%Y+AMOUNT
        END FUNCTION EXT_VEC2D

	TYPE(POINT2D) FUNCTION ADD_POINT2D(PT1,PT2)
	    TYPE(POINT2D),INTENT(IN) :: PT1,PT2
	    ADD_POINT2D%X=PT1%X+PT2%X
	    ADD_POINT2D%Y=PT1%Y+PT2%Y
	END FUNCTION ADD_POINT2D
	
TYPE(FVALUE) FUNCTION ADD_FVALUE(FT1, FT2)
	TYPE(FVALUE), INTENT(IN) :: FT1, FT2

	ADD_FVALUE%D00 = FT1%D00 + FT2%D00
	ADD_FVALUE%D10 = FT1%D10 + FT2%D10
	ADD_FVALUE%D01 = FT1%D01 + FT2%D01
	ADD_FVALUE%D20 = FT1%D20 + FT2%D20
	ADD_FVALUE%D02 = FT1%D02 + FT2%D02
	ADD_FVALUE%D11 = FT1%D11 + FT2%D11

END FUNCTION ADD_FVALUE

!!!!! FUNCTIONS FOR THE NEW OPERATION - !!!!!
	TYPE(POINT2D) FUNCTION SUBTRACT_PT2D(PT1, PT2)
		TYPE(POINT2D), INTENT(IN) :: PT1, PT2
		
		SUBTRACT_PT2D%X = PT1%X - PT2%X
		SUBTRACT_PT2D%Y = PT1%Y - PT2%Y
		
	END FUNCTION SUBTRACT_PT2D
	
!!!!! FUNCTIONS FOR THE NEW OPERATION .AND. !!!!!
	TYPE(RECPATCH) FUNCTION RECPATCH_INTERSECTION(PATCH1,PATCH2)
		TYPE(RECPATCH),INTENT(IN) :: PATCH1,PATCH2
		LOGICAL :: VALIDATION
		REAL(8) :: SX,BX,SY,BY
		
		VALIDATION=VALIDATE_INTERSECTION(PATCH1,PATCH2)
		
		IF (VALIDATION) THEN
			SX=MAX(PATCH1%PT1%X,PATCH2%PT1%X)
			BX=MIN(PATCH1%PT2%X,PATCH2%PT2%X)
			SY=MAX(PATCH1%PT1%Y,PATCH2%PT1%Y)
			BY=MIN(PATCH1%PT3%Y,PATCH2%PT3%Y)

			RECPATCH_INTERSECTION=RECPATCH(POINT2D(SX,SY),POINT2D(BX,SY),&
		                                POINT2D(BX,BY),POINT2D(SX,BY))
		ELSE
			RECPATCH_INTERSECTION=RECPATCH(POINT2D(0.0D0,0.0D0),POINT2D(0.0D0,0.0D0),&
										   POINT2D(0.0D0,0.0D0),POINT2D(0.0D0,0.0D0))
		ENDIF	

	END FUNCTION RECPATCH_INTERSECTION

	LOGICAL FUNCTION VALIDATE_INTERSECTION(PATCH1,PATCH2)
		TYPE(RECPATCH),INTENT(IN) :: PATCH1,PATCH2
		REAL(8) :: SX,BX,SY,BY

		SX=MAX(PATCH1%PT1%X,PATCH2%PT1%X)
		BX=MIN(PATCH1%PT2%X,PATCH2%PT2%X)
		SY=MAX(PATCH1%PT1%Y,PATCH2%PT1%Y)
		BY=MIN(PATCH1%PT3%Y,PATCH2%PT3%Y)

		IF ((BX-SX.GT.5.0D-15) .AND. (BY-SY.GT.5.0D-15)) THEN
			VALIDATE_INTERSECTION=.TRUE.
		ELSE
			VALIDATE_INTERSECTION=.FALSE.
		END IF

	END FUNCTION VALIDATE_INTERSECTION

LOGICAL FUNCTION REC_BELONGTO_REC(SMALL_BOX, BIG_BOX)

TYPE(RECPATCH), INTENT(IN) :: SMALL_BOX, BIG_BOX
	LOGICAL :: MASK(4)
	
	IF (((SMALL_BOX%PT1.IN.BIG_BOX).EQV..TRUE.) .AND. ((SMALL_BOX%PT2.IN.BIG_BOX).EQV..TRUE.) .AND. &
			((SMALL_BOX%PT3.IN.BIG_BOX).EQV..TRUE.) .AND. ((SMALL_BOX%PT4.IN.BIG_BOX).EQV..TRUE.)) THEN
		REC_BELONGTO_REC = .TRUE.
	ELSE
		REC_BELONGTO_REC = .FALSE.
	ENDIF
	
END FUNCTION REC_BELONGTO_REC

LOGICAL FUNCTION BELONGTO_R(PT, RCTNGLE)
	TYPE(POINT2D), INTENT(IN) :: PT
	TYPE(RECPATCH), INTENT(IN) :: RCTNGLE
	
	TYPE(POINT2D) :: R(4)
	LOGICAL :: MASK(4)
	REAL*8 :: TOL, M
	INTEGER :: I
	
	TOL = 5.0D-15
	
	R(1) = RCTNGLE%PT1; R(2) = RCTNGLE%PT2
	R(3) = RCTNGLE%PT3; R(4) = RCTNGLE%PT4
	
	!----- ON BOTTOM LINE OF RECTANGLE -----!
	IF (DABS(R(1)%Y - R(2)%Y).LE.TOL) THEN
		IF (PT%Y-R(1)%Y.GE.TOL) THEN
			MASK(1) = .TRUE.
		ELSEIF (DABS(PT%Y-R(1)%Y).LE.TOL) THEN
			MASK(1) = .TRUE.
		ELSE
			MASK(1) = .FALSE.
		ENDIF
	ELSE!IF ((DABS(R(1)%Y - R(2)%Y).GT.TOL) THEN
		M = (R(2)%Y - R(1)%Y) / (R(2)%X - R(1)%X)
		IF (PT%Y - (M*(PT%X - R(1)%X) + R(1)%Y).GE.TOL) THEN
			MASK(1) = .TRUE.
		ELSEIF (DABS(PT%Y - (M*(PT%X - R(1)%X) + R(1)%Y)).LE.TOL) THEN
			MASK(1) = .TRUE.
		ELSE
			MASK(1) = .FALSE.
		ENDIF
	ENDIF

	!----- ON TOP LINE OF RECTANGLE -----!
	IF (DABS(R(3)%Y - R(4)%Y).LE.TOL) THEN
		IF (PT%Y-R(3)%Y.LE.TOL) THEN
			MASK(3) = .TRUE.
		ELSEIF (DABS(PT%Y - R(3)%Y).LE.TOL) THEN
			MASK(3) = .TRUE.
		ELSE
			MASK(3) = .FALSE.
		ENDIF
	ELSE!IF ((DABS(R(3)%Y - R(4)%Y).GT.TOL) THEN
		M = (R(3)%Y - R(4)%Y) / (R(3)%X - R(4)%X)
		IF (PT%Y - (M*(PT%X - R(4)%X) + R(4)%Y).LE.TOL) THEN
			MASK(3) = .TRUE.
		ELSEIF (DABS(PT%Y - (M*(PT%X - R(4)%X) + R(4)%Y)).LE.TOL) THEN
			MASK(3) = .TRUE.
		ELSE
			MASK(3) = .FALSE.
		ENDIF
	ENDIF

	!----- ON RIGHT LINE OF RECTANGLE -----!
	IF (DABS(R(2)%X - R(3)%X).LE.TOL) THEN
		IF (PT%X-R(2)%X.LE.TOL) THEN
			MASK(2) = .TRUE.
		ELSEIF (DABS(PT%X-R(2)%X).LE.TOL) THEN
			MASK(2) = .TRUE.
		ELSE
			MASK(2) = .FALSE.
		ENDIF
	ELSE!IF ((DABS(R(2)%X - R(3)%X).GT.TOL) THEN
		M = (R(3)%X - R(2)%X) / (R(3)%Y - R(2)%Y)
		IF (PT%X - (M*(PT%Y - R(2)%Y) + R(2)%X).LE.TOL) THEN
			MASK(2) = .TRUE.
		ELSEIF (DABS(PT%X - (M*(PT%Y - R(2)%Y) + R(2)%X)).LE.TOL) THEN
			MASK(2) = .TRUE.
		ELSE
			MASK(2) = .FALSE.
		ENDIF
	ENDIF

	!----- ON LEFT LINE OF RECTANGLE -----!
	IF (DABS(R(4)%X - R(1)%X).LE.TOL) THEN
		IF (PT%X-R(1)%X.GE.TOL) THEN
			MASK(4) = .TRUE.
		ELSEIF (DABS(PT%X-R(1)%X).LE.TOL) THEN
			MASK(4) = .TRUE.
		ELSE
			MASK(4) = .FALSE.
		ENDIF
	ELSE!IF ((DABS(R(4)%X - R(1)%X).GT.TOL) THEN
		M = (R(4)%X - R(1)%X) / (R(4)%Y - R(1)%Y)
		IF (PT%X - (M*(PT%Y - R(1)%Y) + R(1)%X).GE.TOL) THEN
			MASK(4) = .TRUE.
		ELSEIF (DABS(PT%X - (M*(PT%Y - R(1)%Y) + R(1)%X)).LE.TOL) THEN
			MASK(4) = .TRUE.
		ELSE
			MASK(4) = .FALSE.
		ENDIF
	ENDIF
	
	BELONGTO_R = .TRUE.
	DO I=1, 4
		IF (MASK(I).EQV..FALSE.) THEN
			BELONGTO_R = .FALSE.
		ENDIF
	ENDDO

	DO I=1, 4
		IF ((DABS(PT%X - R(I)%X).LE.TOL) .AND. (DABS(PT%Y - R(I)%Y).LE.TOL)) THEN
			BELONGTO_R = .TRUE.
			GOTO 111
		ENDIF
	ENDDO
	111 CONTINUE
	
END FUNCTION BELONGTO_R

LOGICAL FUNCTION LIEON(LN1,LN2)	! LN1 = TEST LINE, LN2 = BOUNDARY
	TYPE(VEC2D), INTENT(IN) :: LN1, LN2
	
	TYPE(POINT2D) :: U(2), V(2)
	REAL*8 :: TOL, Y(2), TEMP, M
	
	LIEON = .FALSE.
	
	TOL = 5.0D-15
	U(1) = LN1%U; U(2) = LN2%U
	V(1) = LN1%V; V(2) = LN2%V
	
	IF (DABS(U(2)%X-V(2)%X).LE.TOL) THEN
		IF ((DABS(U(1)%X-V(1)%X).LE.TOL).AND.(DABS(U(1)%X-U(2)%X).LE.TOL)) THEN
			IF ((((MAX(U(1)%Y, V(1)%Y) - MAX(U(2)%Y, V(2)%Y)).LE.TOL).OR.&
					(DABS(MAX(U(1)%Y, V(1)%Y) - MAX(U(2)%Y, V(2)%Y)).LE.TOL)).AND.&
					(((MIN(U(1)%Y, V(1)%Y) - MIN(U(2)%Y, V(2)%Y)).GE.TOL).OR.&
					(DABS(MIN(U(1)%Y, V(1)%Y) - MIN(U(2)%Y, V(2)%Y)).LE.TOL))) THEN
					LIEON = .TRUE.
			ENDIF
		ENDIF
	ELSEIF (DABS(U(2)%Y-V(2)%Y).LE.TOL) THEN
		IF ((DABS(U(1)%Y-V(1)%Y).LE.TOL).AND.(DABS(U(1)%Y-U(2)%Y).LE.TOL)) THEN
			IF ((((MAX(U(1)%X, V(1)%X) - MAX(U(2)%X, V(2)%X)).LE.TOL).OR.&
					(DABS(MAX(U(1)%X, V(1)%X) - MAX(U(2)%X, V(2)%X)).LE.TOL)).AND.&
					(((MIN(U(1)%X, V(1)%X) - MIN(U(2)%X, V(2)%X)).GE.TOL).OR.&
					(DABS(MIN(U(1)%X, V(1)%X) - MIN(U(2)%X, V(2)%X)).LE.TOL))) THEN
				 LIEON = .TRUE.
			ENDIF
		ENDIF
	ELSE
		IF (V(2)%X.GE.U(2)%X) THEN
			TEMP = U(2)%X
			U(2)%X = V(2)%X
			V(2)%X = TEMP
			TEMP = U(2)%Y
			U(2)%Y = V(2)%Y
			V(2)%Y = TEMP
		ENDIF
		M = (U(2)%Y-V(2)%Y) / (U(2)%X-V(2)%X)
		Y(1) = M*(U(1)%X - V(2)%X) + V(2)%Y
		Y(2) = M*(V(1)%X - V(2)%X) + V(2)%Y
		IF (((MAX(U(1)%X,V(1)%X) - MAX(U(2)%X,V(2)%X)).LE.TOL).AND.((MIN(U(1)%X,V(1)%X) - MIN(U(2)%X,V(2)%X)).GE.TOL).AND.&
				(DABS(Y(1)-U(1)%Y).LE.TOL).AND.(DABS(Y(2)-V(1)%Y).LE.TOL)) THEN
!		IF ((U(1)%X - V(2)%X).GE.TOL.AND.(U(1)%X - U(2)%X).LE.TOL.AND.(DABS(Y(1)-U(1)%Y).LE.TOL).AND.(DABS(Y(2)-V(1)%Y).LE.TOL)) THEN
			LIEON = .TRUE.
		ENDIF
	ENDIF
END FUNCTION LIEON

LOGICAL FUNCTION PTLIEON(PT,LN)	! PT = TEST POINT, LN2 = BOUNDARY
	TYPE(POINT2D), INTENT(IN) :: PT
	TYPE(VEC2D), INTENT(IN) :: LN
	
	TYPE(POINT2D) :: U, V
	REAL*8 :: TOL, Y, TEMP, M

	PTLIEON=.FALSE.
	
	TOL = 5.0D-15
	U = LN%U
	V = LN%V
	
	IF (DABS(U%X-V%X).LE.TOL) THEN
		IF (V%Y.GE.U%Y) THEN
			TEMP = U%Y
			U%Y = V%Y
			V%Y = TEMP
		ENDIF
		IF ((DABS(U%X-PT%X).LE.TOL).AND.(PT%Y.GE.V%Y).AND.(PT%Y.LE.U%Y)) THEN
		    PTLIEON=.TRUE.
		ENDIF
	ELSE
		IF (V%X.GE.U%X) THEN
			TEMP = U%X
			U%X = V%X
			V%X = TEMP
			TEMP = U%Y
			U%Y = V%Y
			V%Y = TEMP
		ENDIF
		M = (U%Y-V%Y) / (U%X-V%X)
		Y = M*(PT%X-V%X)+V%Y
		IF ((PT%X.GE.V%X).AND.(PT%X.LE.U%X).AND.(DABS(Y-PT%Y).LE.TOL)) THEN
			PTLIEON=.TRUE.
		ENDIF
	ENDIF
END FUNCTION PTLIEON

	LOGICAL FUNCTION IS_SAME(PATCH1,PATCH2)
		TYPE(RECPATCH),INTENT(IN) :: PATCH1,PATCH2
		REAL(8) :: DIFFX1,DIFFX2,DIFFY1,DIFFY2

		DIFFX1=(PATCH1%PT1%X-PATCH2%PT1%X)
		DIFFX2=(PATCH1%PT2%X-PATCH2%PT2%X)
		DIFFY1=(PATCH1%PT1%Y-PATCH2%PT1%Y)
		DIFFY2=(PATCH1%PT3%Y-PATCH2%PT3%Y)

		IS_SAME=.FALSE.

		IF ((DIFFX1).LT.5.0D-15.AND.(DIFFX2).LT.5.0D-15.AND.(DIFFY1).LT.5.0D-15.AND.&
		   &(DIFFY2).LT.5.0D-15) THEN
			IS_SAME=.TRUE.
		END IF
	END FUNCTION IS_SAME

	LOGICAL FUNCTION IS_BOUNDARY(PT2D,RECPATCH_TEST)
		TYPE(RECPATCH),INTENT(IN) :: RECPATCH_TEST
		TYPE(POINT2D),INTENT(IN):: PT2D
		REAL(8) :: SX,BX,SY,BY
		REAL(8) :: X,Y

		SX=RECPATCH_TEST%PT1%X
		BX=RECPATCH_TEST%PT2%X
		SY=RECPATCH_TEST%PT1%Y
		BY=RECPATCH_TEST%PT3%Y

		X=PT2D%X
		Y=PT2D%Y

		IS_BOUNDARY=.FALSE.

		IF ((((BX-X).LT.5.0D-15) .OR. ((X-SX).LT.5.0D-15)).AND. &
               (Y.GE.SY.AND.Y.LE.BY)) THEN
			IS_BOUNDARY=.TRUE.
		END IF

		IF (((BY-Y).LT.5.0D-15 .OR. (Y-SY).LT.5.0D-15).AND. &
               (X.GE.SX.AND.X.LE.BX)) THEN
			IS_BOUNDARY=.TRUE.
		END IF

	END FUNCTION IS_BOUNDARY

	CHARACTER (LEN=2) FUNCTION WHICH_BOUNDARY(PT2D,RECPATCH_TEST)
		TYPE(RECPATCH),INTENT(IN) :: RECPATCH_TEST
		TYPE(POINT2D),INTENT(IN):: PT2D
		REAL(8) :: SX,BX,SY,BY
		REAL(8) :: X,Y

		SX=RECPATCH_TEST%PT1%X
		BX=RECPATCH_TEST%PT2%X
		SY=RECPATCH_TEST%PT1%Y
		BY=RECPATCH_TEST%PT3%Y
		
		X=PT2D%X
		Y=PT2D%Y

        ! 'NN' = NONE  'RR' = RIGHT 'LL' = LEFT  'FF' = FORWARD  'KK' = BACKWARD
        ! 'LF' = LEFT/RIGHT  'RF' = RIGHT/FORWARD  'LK' = LEFT/BACKWARD  'RK' = RIGHT/BACKWARD

		WHICH_BOUNDARY='NN'

		IF (((BX-X).LT.5.0D-15).AND. &
               (Y.GE.SY.AND.Y.LE.BY).AND.WHICH_BOUNDARY.EQ.'NN') THEN
			WHICH_BOUNDARY='RR'
        ENDIF
        IF (((X-SX).LT.5.0D-15).AND. &
               (Y.GE.SY.AND.Y.LE.BY).AND.WHICH_BOUNDARY.EQ.'NN') THEN
			WHICH_BOUNDARY='LL'
		END IF

		IF (((BY-Y).LT.5.0D-15).AND. &
               (X.GE.SX.AND.X.LE.BX).AND.WHICH_BOUNDARY.EQ.'NN') THEN
			WHICH_BOUNDARY='KK'
		END IF
		IF (((Y-SY).LT.5.0D-15).AND. &
               (X.GE.SX.AND.X.LE.BX).AND.WHICH_BOUNDARY.EQ.'NN') THEN
			WHICH_BOUNDARY='FF'
		END IF
		IF (((X-SX).LT.5.0D-15).AND.((Y-SY).LT.5.0D-15).AND.WHICH_BOUNDARY.NE.'NN') THEN
			WHICH_BOUNDARY='LF'
		END IF
		IF (((BX-X).LT.5.0D-15).AND.((Y-SY).LT.5.0D-15).AND.WHICH_BOUNDARY.NE.'NN') THEN
			WHICH_BOUNDARY='RF'
		END IF
		IF (((X-SX).LT.5.0D-15).AND.((BY-Y).LT.5.0D-15).AND.WHICH_BOUNDARY.NE.'NN') THEN
			WHICH_BOUNDARY='LK'
		END IF
		IF (((BX-X).LT.5.0D-15).AND.((BY-Y).LT.5.0D-15).AND.WHICH_BOUNDARY.NE.'NN') THEN
			WHICH_BOUNDARY='RK'
		END IF
	END FUNCTION WHICH_BOUNDARY

	!!  OPERATIONS OF MATRICES

	!!  DETERMINANT OF GIVEN MATRIX
	REAL(8) FUNCTION DETERMINANT_MATRIX_22(MAT)

		TYPE(MATRIX_22), INTENT(IN) :: MAT

		DETERMINANT_MATRIX_22 = DABS(MAT%ENT(1,1)*MAT%ENT(2,2) - MAT%ENT(1,2)*MAT%ENT(2,1))

	END FUNCTION DETERMINANT_MATRIX_22

	!!  INVERSE MATRIX
	TYPE(MATRIX_22) FUNCTION INVERSE_MATRIX_22(MAT)

		TYPE(MATRIX_22), INTENT(IN) :: MAT
		TYPE(MATRIX_22) :: DMY_MAT
		INTEGER :: I, J
		REAL(8) :: DET_M, TOL

		TOL = 5.0D-15

		DMY_MAT = MAT
		DO I=1, 2
			DO J=1, 2
				IF (DABS(DMY_MAT%ENT(I,J)).LE.TOL) THEN
					DMY_MAT%ENT(I,J) = 0.D0
				ENDIF
			ENDDO
		ENDDO
		
		DET_M = .DETERMINANT. DMY_MAT
		IF (DABS(DET_M)>TOL) THEN
			INVERSE_MATRIX_22%ENT(1,1) = +DMY_MAT%ENT(2,2)/DET_M
			INVERSE_MATRIX_22%ENT(1,2) = -DMY_MAT%ENT(1,2)/DET_M
			INVERSE_MATRIX_22%ENT(2,1) = -DMY_MAT%ENT(2,1)/DET_M
			INVERSE_MATRIX_22%ENT(2,2) = +DMY_MAT%ENT(1,1)/DET_M
		ELSE
! 			PRINT *, '[ERROR]  THE DETERMINANT OF GIVEN MATRIX IS ZERO !'
! 			STOP
			INVERSE_MATRIX_22%ENT(1,1) = 0.0D0
			INVERSE_MATRIX_22%ENT(1,2) = 0.0D0
			INVERSE_MATRIX_22%ENT(2,1) = 0.0D0
			INVERSE_MATRIX_22%ENT(2,2) = 0.0D0
		ENDIF

	END FUNCTION INVERSE_MATRIX_22

	!!  TRANSPOSE MATRIX
	TYPE(MATRIX_22) FUNCTION TRANSPOSE_MATRIX_22(MAT)

		TYPE(MATRIX_22), INTENT(IN) :: MAT
		INTEGER :: I, J

		DO I=1,2
		DO J=1,2
			TRANSPOSE_MATRIX_22%ENT(I,J) = MAT%ENT(J,I)
		ENDDO
		ENDDO

	END FUNCTION TRANSPOSE_MATRIX_22

SUBROUTINE GET_RTHETA(R, THETA, PT)
	TYPE(POINT2D), INTENT(IN) :: PT
	REAL*8, INTENT(OUT) :: R, THETA
	REAL*8 :: X, Y

	X = PT%X; Y = PT%Y
	
	R = DSQRT(X**2 + Y**2)

	IF (DABS(R).LE.TOLERANCE) THEN
		THETA = 0.0D0
	ELSEIF (X.GT.TOLERANCE.AND.DABS(Y).LE.TOLERANCE.AND.DABS(R).GT.TOLERANCE) THEN
		THETA = 0.0D0
	ELSEIF (X.LT.-TOLERANCE.AND.DABS(Y).LE.TOLERANCE.AND.DABS(R).GT.TOLERANCE) THEN
		THETA = DACOS(-1.D0)
	ELSEIF (Y.GT.TOLERANCE.AND.DABS(X).LE.TOLERANCE.AND.DABS(R).GT.TOLERANCE) THEN
		THETA = 0.5D0*DACOS(-1.0D0)
	ELSEIF (Y.LT.-TOLERANCE.AND.DABS(X).LE.TOLERANCE.AND.DABS(R).GT.TOLERANCE) THEN
		THETA = 1.5D0*DACOS(-1.0D0)
	ELSEIF (Y.GT.TOLERANCE.AND.DABS(X).GT.TOLERANCE.AND.DABS(R).GT.TOLERANCE) THEN
		THETA = DACOS(X/R)
	ELSEIF (Y.LT.-TOLERANCE.AND.DABS(X).GT.TOLERANCE.AND.DABS(R).GT.TOLERANCE) THEN
		THETA = 2.D0*DACOS(-1.D0) - DACOS(X/R)
	ENDIF
	
END SUBROUTINE GET_RTHETA

INTEGER FUNCTION FACTORIAL(A)

	INTEGER, INTENT(IN) :: A
	INTEGER :: I

	FACTORIAL = 1

	IF (A.LT.0) THEN
		PRINT*, 'ERROR - FACTORIAL : INPUT ARGUMENT IS NEGATIVE INTEGER'
		PRINT*, 'A = ', A
		STOP
	ELSE
		DO I=1, A
			FACTORIAL = FACTORIAL*I
		ENDDO
	ENDIF

END FUNCTION FACTORIAL

REAL*8 FUNCTION COMBINATION(A,B)
	
	INTEGER, INTENT(IN) :: A, B
	INTEGER :: I, J, TOP, BOTTOM(2)

	TOP = FACTORIAL(A)
	BOTTOM(1) = FACTORIAL(B)
	BOTTOM(2) = FACTORIAL(A-B)

	COMBINATION = 1.D0*TOP/(1.D0*BOTTOM(1)*BOTTOM(2))

END FUNCTION COMBINATION

END MODULE NEWTYPE

