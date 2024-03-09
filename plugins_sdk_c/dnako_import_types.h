/*
�Ȃł����ŗ��p����^�̒�`
*/
#ifndef	dnako_import_types_h__
#define	dnako_import_types_h__

#include <windows.h>

#ifdef NAKO_API_EXPORTS
#  define NAKO_API(rettype) __declspec(dllexport) rettype __stdcall
#else
#  define NAKO_API __declspec(dllimport)
#endif

typedef char* PAnsiChar;
typedef char* PAnsiString;
typedef unsigned long HFloat,*PHFloat;

typedef enum __THiVType{varNil = 0, varInt=1, varFloat=2, varStr=3, varPointer=4,
    varFunc=5, varArray=6, varHash=7, varGroup=8, varLink=9}THiVType;

#pragma pack(push,1)
typedef struct tagTHiValue{
    BYTE		VType; // �l�̌^
    int			Size;  // �l�̑傫��
    DWORD		VarID;    // �ϐ���
    int			RefCount;  // �Q�ƃJ�E���g for GC
    struct tagTHiValue	*Setter; // Setter
    struct tagTHiValue	*Getter; // Getter
    BYTE		ReadOnly;     // ReadOnly = 1
    BYTE		Registered;   // ������Ă悢�l���H(���ꂪ1�Ȃ珟��ɉ�����Ă͂Ȃ�Ȃ�)
    BYTE		Flag1;
    BYTE		Flag2;
    union {//case Byte of
    int integer; // varInt
    void *ptr; // other...
    char *ptr_s; // varStr
	};
} THiValue;
#pragma pack(pop)

typedef THiValue* PHiValue;

typedef PHiValue(__stdcall *THimaSysFunction)(DWORD);
typedef double	Double;
typedef double	Extended; // todo: �������Ȃ����Ƃ肠�����K��

extern PHiValue hi_var_new(char* name);
// �V�K�ϐ��𐶐�����
extern PHiValue hi_clone(PHiValue v); // �֐��Ƃ܂������������̂𐶐�����
extern PHiValue hi_newInt(int value); // �V�K����
extern PHiValue hi_newStr(char* value);  // �V�K������
extern PHiValue hi_newFloat(HFloat value);// �V�K������
// �������Z�b�g����
extern void hi_setInt  (PHiValue v,int num);
extern void hi_setFloat(PHiValue v,HFloat num);
// BOOL�^���Z�b�g����
extern void hi_setBool(PHiValue v,BOOL b);
// ��������Z�b�g����
extern void hi_setStr(PHiValue v,char* s, int len);
// �L���X�g���Ďg����悤��
extern BOOL hi_bool(PHiValue value);
extern int hi_int  (PHiValue value);
extern double hi_float(PHiValue value);
extern char* hi_str(PHiValue p);

#endif //dnako_import_types_h__

