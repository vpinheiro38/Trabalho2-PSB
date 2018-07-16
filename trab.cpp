#include <iostream>
using namespace std;

void quicksort(int values[], int began, int end)
{
	cout << "Teste\n";
	for(int i = 0; i < 2; i++)
	{
		cout << values[i] << ' ';
	}
	cout << endl;
	
	int i, j, pivo, aux;
	i = began;
	j = end-1;
	pivo = values[(began + end) / 2];
	while(i <= j)
	{
		while(values[i] < pivo && i < end)
		{
			cout << "A\n";
			i++;
		}
		while(values[j] > pivo && j > began)
		{
			cout << "B\n";
			j--;
		}
		if(i <= j)
		{
			aux = values[i];
			values[i] = values[j];
			values[j] = aux;
			i++;
			j--;
		}
	}
	if(j > began)
		quicksort(values, began, j+1);
	if(i < end)
		quicksort(values, i, end);
}

int main(int argc, char *argv[])
{
	int array[2] = {2, 1};
	char ent[100];
	
	//cin >> ent;
	
	for(int i = 0; i < 2; i++)
	{
		cout << array[i] << ' ';
	}
	
	quicksort(array, 0, 2);
	
	for(int i = 0; i < 2; i++)
	{
		cout << array[i] << ' ';
	}
	
	return 0;
}
