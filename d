#define  _CRT_SECURE_NO_WARNINGS 1
#include <iostream>
#include <string>
#include <assert.h>
using namespace std;
#define MAX 0X7fffffffffffffff
#define S_M 0Xcccccccccccccccc
#define MIN MAX+1
class BigData
{
private:
	string _strdata;
	long long _value;
public:
	BigData(long long value)
		:_value(value)
	{
		char symbol = '+';
		if (value < 0)
		{
			symbol = '-';
		}
		long long num = value;
		int count = 0;
		while (num)
		{
			count++;
			num = num /(long long)10;
			
		}
		_strdata.resize(count + 1);
		_strdata[0] = symbol;
		if (value < 0)
		{
			value = 0 - value;
		}
		for (int i = count; i >= 1; i--)
		{
			num = value % 10;
			value = value / 10;
			_strdata[i] = num+'0';
		}
	}
	BigData(char *str = "")
	{
		//将字符转化为整数
		//"+12345" "_12345" "a123" "12345adc" "12345" "+0000123"
		char symbol = str[0];
		if (*str >= '0' && *str <= '9')
		{
			symbol = '+';
		}
		else if (symbol == '+' || symbol == '-')
		{
			str++;
		}
		else
		{
			_value = S_M;
			return;
		}
		while (*str == '0')
		{
			str++;
		}
		//将符号位和有效数字存入
		_strdata.resize(strlen(str) + 1);
		_strdata[0] = symbol;
		if (*str > '9' || *str < '0')
		{
			cout << _value;
			return;
		}
		int count = 1;
		_value = 0;
		while (*str >= '0'&&*str <= '9')
		{
			_strdata[count++] = *str;
			_value = _value * 10 + *str - '0';
			str++;
		}
		_strdata.resize(count);
		if (symbol == '-')
		{
			_value = 0 - _value;
		}
	}
	BigData operator +(const BigData &b)
	{
		//判断数是否溢出
		//溢出：两个数中至少有一个溢出   两个数的结果溢出
		if (!Isoverflow() && !b.Isoverflow())
		{
			if (_strdata[0] != b._strdata[0])
			{
				return BigData(_value + b._value);
			}
			else if ((_strdata[0] == '+'&& MAX - _value >= b._value) || (_strdata[0] == '-'&&MIN - _value <= b._value))
			{
				return BigData(_value + b._value);
			}
		}
		return BigData((char *)(ADD(_strdata, b._strdata)).c_str());
	}
	BigData operator-(const BigData &b)
	{
		if (!Isoverflow() && !b.Isoverflow())
		{
			if (_strdata[0] == b._strdata[0])
			{
				return BigData(_value - b._value);
			}
			else
			{
				if ((_strdata[0] == '+' && 0 - (MAX - _value)<= b._value) || (_strdata[0] == '-'&&MIN - _value <= 0 - b._value))
				{
					return _value - b._value;
				}
			}
		}
		if (_strdata[0]!=b._strdata[0] )
		{

			return BigData((char *)(ADD(_strdata, b._strdata)).c_str());
		}
		return BigData((char *)(SUB(_strdata, b._strdata)).c_str());
	}
	string SUB(string left,string right)
	{
		//同号溢出
			string tmp("");
			int Lsize =left.size();
			int Rsize = right.size();
			char symbol = left[0];
			if (Rsize > Lsize || Rsize==Lsize&&left<right)
			{
				//找出两个中最大的size
				swap(Lsize, Rsize);
				swap(left, right);
				if (left[0] == '-')
				{
					symbol = '+';
				}
				else
					symbol = '-';
			}
			string tem;
			tem.resize(Lsize);
			tem[0] = symbol;
			for (int i = 1; i < Lsize; i++)
			{
				char cRet = left[Lsize - i] - '0';
				if (i < Rsize)
				{
					cRet = cRet - (right[Rsize - i] - '0');	
					if (cRet < 0)
					{
						cRet += 10;
						left[Lsize - i - 1] = left[Lsize - i - 1] - '0' - 1;
					}
				}
				tem[Lsize - i] = cRet + '0';
			}
			return tem;
	}
	string ADD(string left,string right)
	{
		string tmp("");
		char symbol = left[0];
		int Lsize = left.size();
		int Rsize = right.size();
		if (Rsize > Lsize)
		{
			//找出两个中最大的size
			symbol = right[0];
			swap(Lsize, Rsize);
			swap(left, right);
		}
		tmp.resize(Lsize + 1);
		tmp[0] = symbol;
		char cy = 0;
		int by = 0;
		if (left[0] == right[0])
		{
			for (int i = 1; i < Lsize; i++)
			{
				by = left[Lsize - i] + cy - '0';
				if (i < Rsize)
				{
					by = by + right[Rsize - i] - '0';
				}
				tmp[Lsize - i + 1] = by % 10 + '0';
				cy = by / 10;
			}
			tmp[1] = cy + '0';
		}
		else
		{
			for (int i = 1; i < Lsize; i++)
			{
				by = left[Lsize - i]  - '0';
				if (i < Rsize)
				{
					by = by-(right[Rsize - i] - '0');
				}
				if (by < 0)
				{
					left[Lsize - i - 1] = (left[Lsize - i - 1] - '0') - 1;
					by += 10;
				}
				tmp[Lsize - i] = by + '0';
			}
			
		}
		return tmp;
	}
	BigData operator *(const BigData &b)
	{
		if (!Isoverflow() && !b.Isoverflow())
		{
			if (_strdata[0] == b._strdata[0])
			{
				if ((_strdata[0] == '+'&&MAX / _value >= b._value) || (_strdata[0] == '-'&& MAX / _value <= b._value))
				{
					return BigData(_value*b._value);
				}
			}
			else
			{
				if ((_strdata[0] == '+'&&MIN / _value <= b._value) || (_strdata[0] == '-'&&MIN / _value >= b._value))
				{
					return BigData(_value*b._value);
				}
			}
		}
		return BigData((char *)MUL(_strdata, b._strdata).c_str());
	}
	string MUL(string left, string right)
	{
		if (left=="0"||right=="0")
		{
			return string("0");
		}
		int lsize = left.size();
		int rsize = right.size();
		if (lsize > rsize)
		{
			swap(lsize, rsize);
			swap(left, right);
		}
		char symbol = left[0];
		if (left[0] != right[0])
		{
			symbol = '-';
		}
		string tem;
		tem.resize(lsize + rsize - 1);
		tem[0] = symbol;
		char cstep = 0;
		int s = 0;
		int i = 0;
		int j = 0;
		for ( i = 1; i < lsize; i++)
		{
			cstep = 0;
			char cRet = left[lsize - i] - '0';
			for ( j = 1; j < rsize; j++)
			{
				cRet = cRet*(right[rsize - i] - '0');
				cRet += cstep;
				cRet += tem[lsize + rsize - 1 - j - s] - '0';
				cstep = cRet / 10;
			}
			tem[lsize + rsize - 1 - j-s] = cRet % 10 + '0';
			s++;
		}
		return tem;
	}
	bool Isleft(char *left,int  lsize, char *right,int rsize)
	{
		if (lsize > rsize || lsize == rsize &&strncpy(left, right, lsize))
		{
			return true;
		}
		return false;
	}
	char subloop(char *left,int lsize, char *right,int rsize)
	{
		char count = 0;
		while (true)
		{
			if (!Isleft(left, lsize, right, rsize))
			{
				break;
			}
			int i = lsize - 1;
			int j = rsize - 1;
			while (j >= 0)
			{
				char cRet = left[i] - '0';
				cRet -= right[j] - '0';
				if (cRet < 0)
				{
					left[i - 1] -= 1;
					cRet += 10;
				}
				left[i] = cRet + '0';
				i--;
				j--;
			}
			while (*left == 0 && lsize>0)
			{
				left++;
				lsize--;
			}
			count++;
		}
		return count+'0';
	}
	BigData operator /(const BigData &b)
	{
		if (b._value == 0)
		{
			assert(false);
		}
		if (_strdata.size() < b._strdata.size() || (_strdata.size() == b._strdata.size() && strcmp(_strdata.c_str() + 1, b._strdata.c_str() + 1) < 0))
		{
			return BigData("0");
		}
		if (!Isoverflow() && !b.Isoverflow())
		{
			return BigData(_value / b._value);
		}
		if (strcmp(_strdata.c_str() + 1, b._strdata.c_str() + 1) == 0)
		{
			if (_strdata[0] == b._strdata[0])
			{
				return BigData(1);
			}
			else
			{
				return BigData(-1);
			}
		}
		if (!b.Isoverflow() && ((b._value == 1) || (b._value == -1)))
		{
			if (b._value == 1)
			{
				return *this;
			}
			else
			{
				if (_strdata[0] == '-')
				{
					_strdata[0] = '+';
				}
				else
				{
					_strdata[0] = '-';
				}
			}
		}
		return BigData((char *)(DIV(_strdata, b._strdata)).c_str());
			
	}
	string DIV(string left, string right)
	{
		char symbol = '+';
		if (left[0] != right[0])
		{
			symbol = '-';
		}
		string strRet;
		strRet.append(1,symbol);//追加
		char *pleft = (char *)left.c_str() + 1;
		char *pright = (char *)right.c_str() + 1;
		char len = 1;
		int lsize = left.size() - 1;
		int rsize = right.size() - 1;
		for (int i = 0; i < lsize;i++)
		{
			if (*pleft == '0')
			{
				pleft++;
				i++;
				strRet.append(1, '0');
			}
			if (!Isleft(pleft, len, pright, right.size() - 1))
			{
 				strRet.append(1, '0');
				len++;
				if (i + len >lsize)
				{
					break;
				}
				continue;
			}
			else
			{
				strRet.append(1,subloop(pleft, len, pright, right.size()));
				while (*pleft == '0'&& len>0)
				{
					pleft++;
					len--;
					i++;
				}
				len++;
			}
		}
		return strRet;
	}
	ostream &operator<<(ostream &os)
	{
		if (!Isoverflow())
		{
			os << _value;
		}
		else
		{
			os <<_strdata;
		}
		return os;
	}
	bool Isoverflow()const
	{
		string tem("+9223372036854775807");
		if (_strdata[0]  =='-')
		{
			string tem("+9223372036854775807+1");
		}
		if (_strdata.size() < tem.size())
		{
			return false;
		}
		else if (_strdata.size() == tem.size()&&_strdata<tem)
		{
			return false;
		}
		return true;
	}
};
void test()
{
	BigData s(11);
	BigData s1(-123456789000111111);
	(s.operator+(s1))<<cout;
}
int main()
{
	test();
	getchar();
	return 0;
}
	
