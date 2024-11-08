uint_xlen_t sbclr(uint_xlen_t rs1, uint_xlen_t rs2)
{
    int shamt = rs2 & (XLEN - 1);
    return rs1 & ~(uint_xlen_t(1) << shamt);
}

| 0100100 | rs2 | rs1 | 001 | rd | 0110011 | SBCLR


uint_xlen_t ctz(uint_xlen_t rs1)
{
    for (int count = 0; count < XLEN; count++)
        if ((rs1 >> count) & 1)
            return count;
    return XLEN;
}

| 0110000 | 00001 | rs1 | 001 | rd | 0010011 | CTZ


uint_xlen_t xnor(uint_xlen_t rs1, uint_xlen_t rs2)
{
    return rs1 ^ ~rs2;
}

| 0100000 | rs2 | rs1 | 100 | rd | 0110011 | XNOR
