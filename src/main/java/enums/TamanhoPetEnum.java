package enums;

public enum TamanhoPetEnum {
	MUITO_PEQUENO(1, "1 - Muito Pequeno"),
    PEQUENO(2, "2 - Pequeno"),
    MEDIO(3, "3 - Médio"),
    GRANDE(4, "4 - Grande");

    private final int id;
    private final String descricao;

    TamanhoPetEnum(int id, String descricao) {
        this.id = id;
        this.descricao = descricao;
    }

    public int getId() {
        return id;
    }

    public String getDescricao() {
        return descricao;
    }

    @Override
    public String toString() {
        return getDescricao();
    }
}
