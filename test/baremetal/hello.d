extern(C) int main()
{
    import std.algorithm, std.range;
    assert(100.iota.stride(2).take(10).sum == 90);
    return 0;
}
