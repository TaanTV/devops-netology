Задача 3.
3-1

Напишите программу для перевода метров в футы (1 фут = 0.3048 метр). Можно запросить исходные данные у пользователя, а можно статически задать в коде. Для взаимодействия с пользователем можно использовать функцию Scanf:
````
package main

import "fmt"

func main() {
    fmt.Print("Enter a number: ")
    var input float64
    fmt.Scanf("%f", &input)

    output := input * 2

    fmt.Println(output)    
}
````
Ответ:
````
package main
import "fmt"
func add(a int, b int) int {
 return a / b
}
func main() {
 fmt.Println("делим ", add(20, 10))
}
````

3-2

Напишите программу, которая найдет наименьший элемент в любом заданном списке, например:

````
ackage main

import "fmt"

func main() {

        primes := []int{11, -4, 7, 8, -10}
        min, max := findMinAndMax(primes)
        fmt.Println("Min: ", min)
        fmt.Println("Max: ", max)

}

func findMinAndMax(primes []int) (min int, max int) {
        min = primes[0]
        max = primes[0]
        for _, value := range primes {
                if value < min {
                        min = value
                }
                if value > max {
                        max = value
                }
        }
        return min, max
}
````






3-3
Напишите программу, которая выводит числа от 1 до 100, которые делятся на 3. То есть (3, 6, 9, …).

````
package main

import "fmt"

func main() {
    for i := 1; i <= 100; i++ {
        // сюда поместим ответ при кратности
        output := ""
        // если кратно трем
        if (i % 3 == 0) {
            output += "i"
        }
        // вывод результата
        if (output != "i") {
            fmt.Println(output)
        } else {
            fmt.Println(i)
        }
    }
}
````