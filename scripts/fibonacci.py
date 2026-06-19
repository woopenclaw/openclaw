def fibonacci(n):
    """计算斐波那契数列前 n 个数"""
    if n <= 0:
        return []
    if n == 1:
        return [0]
    
    fib = [0, 1]
    for i in range(2, n):
        fib.append(fib[i-1] + fib[i-2])
    return fib

# 计算前 10 个数
result = fibonacci(10)
print("斐波那契数列前 10 个数：")
print(result)
print()
print("详细输出：")
for i, num in enumerate(result, 1):
    print(f"第{i:2d}个数：{num}")
