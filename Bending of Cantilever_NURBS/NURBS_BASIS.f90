MODULE NURBS_BASIS

	USE GLBVAR
	USE PATCH_MAPPING

	IMPLICIT INTEGER (I-N)
	IMPLICIT REAL(8) (A-H,O-Z)

CONTAINS

!!  GET BASIS FUNCTION ON PHYSICAL SPACE

TYPE(FVALUE) FUNCTION GET_PHY_BASIS_IN_INT(REF_PT,IX,IY, JACOB)

	TYPE(POINT2D), INTENT(IN) :: REF_PT
	INTEGER, INTENT(IN) :: IX, IY
	TYPE(MATRIX_22), INTENT(IN) :: JACOB

	TYPE(MATRIX_22) :: INV_JACOB
	TYPE(SECOND_PARTIAL_DERIVATIVES) :: SECOND_PD
	REAL(8) :: J, JXI, JETA, S(2,3)
	TYPE(FUNCTION_2D) :: REF_SF

	INV_JACOB = .INVERSE.JACOB					!! P(XI)/P(X), P(XI)/P(Y) // P(ETA)/P(X), P(ETA)/P(Y)

	REF_SF = GET_BASIS(REF_PT,(/IX,IY/))

	GET_PHY_BASIS_IN_INT%D00 = REF_SF%VAL(0,0)
	GET_PHY_BASIS_IN_INT%D10 = REF_SF%VAL(1,0)*INV_JACOB%ENT(1,1) + REF_SF%VAL(0,1)*INV_JACOB%ENT(2,1)
	GET_PHY_BASIS_IN_INT%D01 = REF_SF%VAL(1,0)*INV_JACOB%ENT(1,2) + REF_SF%VAL(0,1)*INV_JACOB%ENT(2,2)

END FUNCTION GET_PHY_BASIS_IN_INT

TYPE(FVALUE) FUNCTION GET_PHY_BASIS(REF_PT,IX,IY)

	TYPE(POINT2D), INTENT(IN) :: REF_PT
	INTEGER, INTENT(IN) :: IX, IY

	TYPE(MATRIX_22) :: JACOB, INV_JACOB
	TYPE(SECOND_PARTIAL_DERIVATIVES) :: SECOND_PD
	REAL(8) :: J, JXI, JETA, S(2,3)
	TYPE(FUNCTION_2D) :: REF_SF

	JACOB = GET_JACOBIAN_MATRIX(REF_PT)			!! P(X)/P(XI), P(X)/P(ETA) // P(Y)/P(XI), P(Y)/P(ETA)
	INV_JACOB = .INVERSE.JACOB					!! P(XI)/P(X), P(XI)/P(Y) // P(ETA)/P(X), P(ETA)/P(Y)

! 	SECOND_PD = GET_PARTIAL(REF_PT)				!! P^2(X)/P(XI^2), P^2(X)/P(XI,ETA), P^2(X)/P(ETA^2), P^2(Y)/P(XI^2), P^2(Y)/P(XI,ETA), P^2(Y)/P(ETA^2)
! 
!  	J = JACOB%ENT(1,1)*JACOB%ENT(2,2)-JACOB%ENT(1,2)*JACOB%ENT(2,1)
! 	JXI = SECOND_PD%X(1)*JACOB%ENT(2,2)+JACOB%ENT(1,1)*SECOND_PD%Y(2)-SECOND_PD%X(2)*JACOB%ENT(2,1)-JACOB%ENT(1,2)*SECOND_PD%Y(1)
! 	JETA = SECOND_PD%X(2)*JACOB%ENT(2,2)+JACOB%ENT(1,1)*SECOND_PD%Y(3)-SECOND_PD%X(3)*JACOB%ENT(2,1)-JACOB%ENT(1,2)*SECOND_PD%Y(2)

! 	S(1,1) = -(JXI*JACOB%ENT(2,2)*JACOB%ENT(2,2)-JETA*JACOB%ENT(2,1)*JACOB%ENT(2,2))/J**3+(SECOND_PD%Y(2)*JACOB%ENT(2,2)-SECOND_PD%Y(3)*JACOB%ENT(2,1))/J**2
! 	S(1,2) = (JXI*JACOB%ENT(1,2)*JACOB%ENT(2,2)-JETA*JACOB%ENT(1,2)*JACOB%ENT(2,1))/J**3-(SECOND_PD%X(2)*JACOB%ENT(2,2)-SECOND_PD%X(3)*JACOB%ENT(2,1))/J**2
! 	S(1,3) = -(JXI*JACOB%ENT(1,2)*JACOB%ENT(1,2)-JETA*JACOB%ENT(1,1)*JACOB%ENT(1,2))/J**3+(SECOND_PD%X(2)*JACOB%ENT(1,2)-SECOND_PD%X(3)*JACOB%ENT(1,1))/J**2
! 	S(2,1) = (JXI*JACOB%ENT(2,1)*JACOB%ENT(2,2)-JETA*JACOB%ENT(2,1)*JACOB%ENT(2,1))/J**3-(SECOND_PD%Y(1)*JACOB%ENT(2,2)-SECOND_PD%Y(2)*JACOB%ENT(2,1))/J**2
! 	S(2,2) = -(JXI*JACOB%ENT(1,1)*JACOB%ENT(2,2)-JETA*JACOB%ENT(1,1)*JACOB%ENT(2,1))/J**3+(SECOND_PD%X(1)*JACOB%ENT(2,2)-SECOND_PD%X(2)*JACOB%ENT(2,1))/J**2
! 	S(2,3) = (JXI*JACOB%ENT(1,1)*JACOB%ENT(1,2)-JETA*JACOB%ENT(1,1)*JACOB%ENT(1,1))/J**3-(SECOND_PD%X(1)*JACOB%ENT(1,2)-SECOND_PD%X(2)*JACOB%ENT(1,1))/J**2

	REF_SF = GET_BASIS(REF_PT,(/IX,IY/))

	GET_PHY_BASIS%D00 = REF_SF%VAL(0,0)
	GET_PHY_BASIS%D10 = REF_SF%VAL(1,0)*INV_JACOB%ENT(1,1) + REF_SF%VAL(0,1)*INV_JACOB%ENT(2,1)
	GET_PHY_BASIS%D01 = REF_SF%VAL(1,0)*INV_JACOB%ENT(1,2) + REF_SF%VAL(0,1)*INV_JACOB%ENT(2,2)
! 	GET_PHY_BASIS%D20 = REF_SF%VAL(2,0)*INV_JACOB%ENT(1,1)**2 + 2.0D0*REF_SF%VAL(1,1)*INV_JACOB%ENT(1,1)*INV_JACOB%ENT(2,1) + REF_SF%VAL(0,2)*INV_JACOB%ENT(2,1)**2 + REF_SF%VAL(1,0)*S(1,1) + REF_SF%VAL(0,1)*S(2,1)
! 	GET_PHY_BASIS%D11 = REF_SF%VAL(2,0)*INV_JACOB%ENT(1,1)*INV_JACOB%ENT(1,2) + REF_SF%VAL(1,1)*(INV_JACOB%ENT(1,1)*INV_JACOB%ENT(2,2)+INV_JACOB%ENT(1,2)*INV_JACOB%ENT(2,1)) + REF_SF%VAL(0,2)*INV_JACOB%ENT(2,1)*INV_JACOB%ENT(2,2) + REF_SF%VAL(1,0)*S(1,2) + REF_SF%VAL(0,1)*S(2,2)
! 	GET_PHY_BASIS%D02 = REF_SF%VAL(2,0)*INV_JACOB%ENT(1,2)**2 + 2.0D0*REF_SF%VAL(1,1)*INV_JACOB%ENT(1,2)*INV_JACOB%ENT(2,2) + REF_SF%VAL(0,2)*INV_JACOB%ENT(2,2)**2 + REF_SF%VAL(1,0)*S(1,3) + REF_SF%VAL(0,1)*S(2,3)

END FUNCTION GET_PHY_BASIS

!! FIND ALL NONVANISHING BASIS FUNCTION ON PHYSICAL SPACE
SUBROUTINE GET_ALL_PHY_BASIS_IN_INT(SF, INDX, REF_PT, JACOB)
	TYPE(FVALUE), INTENT(OUT) :: SF((BASIS_KVEC(1)%POLY_ORDER+1)*(BASIS_KVEC(2)%POLY_ORDER+1))
	TYPE(INT2D), INTENT(OUT) :: INDX((BASIS_KVEC(1)%POLY_ORDER+1)*(BASIS_KVEC(2)%POLY_ORDER+1))
	TYPE(POINT2D), INTENT(IN) :: REF_PT
	TYPE(MATRIX_22), INTENT(IN) :: JACOB

	TYPE(DIFF_BSPLINES) :: NX, NY
	TYPE(MATRIX_22) :: INV_JACOB
	
	INV_JACOB = .INVERSE.JACOB
	
	NX = GET_ALL_DIFF_BSPLINES(REF_PT%X, BASIS_KVEC(1), 1)
	NY = GET_ALL_DIFF_BSPLINES(REF_PT%Y, BASIS_KVEC(2), 1)

	K = 0
	DO J=0, NY%POLY_ORDER
		DO I=0, NX%POLY_ORDER
			K = K + 1
			SF(K)%D00 = NX%N(I,0)*NY%N(J,0)
			SF(K)%D10 = NX%N(I,1)*NY%N(J,0)*INV_JACOB%ENT(1,1) + NX%N(I,0)*NY%N(J,1)*INV_JACOB%ENT(2,1)
			SF(K)%D01 = NX%N(I,1)*NY%N(J,0)*INV_JACOB%ENT(1,2) + NX%N(I,0)*NY%N(J,1)*INV_JACOB%ENT(2,2)
			INDX(K) = INT2D(NX%INIT+I, NY%INIT+J)
		ENDDO
	ENDDO
! 	PRINT*, INDX(1),SF(1)
! 	STOP
END SUBROUTINE GET_ALL_PHY_BASIS_IN_INT

!! FIND ALL NONVANISHING BASIS FUNCTION ON PHYSICAL SPACE
SUBROUTINE GET_ALL_PHY_BASIS(SF, INDX, REF_PT)
	TYPE(FVALUE), INTENT(OUT) :: SF((BASIS_KVEC(1)%POLY_ORDER+1)*(BASIS_KVEC(2)%POLY_ORDER+1))
	TYPE(INT2D), INTENT(OUT) :: INDX((BASIS_KVEC(1)%POLY_ORDER+1)*(BASIS_KVEC(2)%POLY_ORDER+1))
	TYPE(POINT2D), INTENT(IN) :: REF_PT

	TYPE(DIFF_BSPLINES) :: NX, NY
	TYPE(MATRIX_22) :: INV_JACOB, JACOB
	
	JACOB = GET_JACOBIAN_MATRIX(REF_PT)			!! P(X)/P(XI), P(X)/P(ETA) // P(Y)/P(XI), P(Y)/P(ETA)
	INV_JACOB = .INVERSE.JACOB
	
	NX = GET_ALL_DIFF_BSPLINES(REF_PT%X, BASIS_KVEC(1), 1)
	NY = GET_ALL_DIFF_BSPLINES(REF_PT%Y, BASIS_KVEC(2), 1)

	K = 0
	DO J=0, NY%POLY_ORDER
		DO I=0, NX%POLY_ORDER
			K = K + 1
			SF(K)%D00 = NX%N(I,0)*NY%N(J,0)
			SF(K)%D10 = NX%N(I,1)*NY%N(J,0)*INV_JACOB%ENT(1,1) + NX%N(I,0)*NY%N(J,1)*INV_JACOB%ENT(2,1)
			SF(K)%D01 = NX%N(I,1)*NY%N(J,0)*INV_JACOB%ENT(1,2) + NX%N(I,0)*NY%N(J,1)*INV_JACOB%ENT(2,2)
			INDX(K) = INT2D(NX%INIT+I, NY%INIT+J)
		ENDDO
	ENDDO

END SUBROUTINE GET_ALL_PHY_BASIS

!!  FIND BASIS FUNCTION ON PARAMETRIC SPACE
TYPE(FUNCTION_2D) FUNCTION GET_BASIS(REF_PT,INDX)

	TYPE(POINT2D), INTENT(IN) :: REF_PT
	INTEGER, INTENT(IN) :: INDX(2)

	TYPE(FUNCTION_1D) :: NX, NY

	NX = GET_DIFF_BSPLINE(REF_PT%X,BASIS_KVEC(1),INDX(1),1)
	NY = GET_DIFF_BSPLINE(REF_PT%Y,BASIS_KVEC(2),INDX(2),1)

	GET_BASIS%VAL(0,0) = NX%VAL(0) * NY%VAL(0)
	GET_BASIS%VAL(1,0) = NX%VAL(1) * NY%VAL(0)
	GET_BASIS%VAL(0,1) = NX%VAL(0) * NY%VAL(1)
! 	GET_BASIS%VAL(2,0) = NX%VAL(2) * NY%VAL(0)
! 	GET_BASIS%VAL(1,1) = NX%VAL(1) * NY%VAL(1)
! 	GET_BASIS%VAL(0,2) = NX%VAL(0) * NY%VAL(2)

END FUNCTION GET_BASIS

END MODULE NURBS_BASIS