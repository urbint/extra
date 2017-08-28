defprotocol Monoid do
  @moduledoc """
  Monoids extend semigroups, objects with an associative binary operator, by adding the notion of
  an identity element.

  Given the `mcat` operator as `⋅`, monoids must satisfy:

    ∀ a. identity ⋅ a = a ⋅ identity = a
    ∀ a b c. a ⋅ (b ⋅ c) = (a ⋅ b) ⋅ c

  ## Built-in instances

  Built in instances are defined for `List`, `Map`, and `Stream`. For example:

    iex> Monoid.mplus([1, 2], [3, 4])
    [1, 2, 3, 4]

    iex> Monoid.identity([1, 2, 3])
    []

    iex> Monoid.identity(%{foo: :bar})
    %{}
  """

  @doc """
  The associative binary operator over objects of this monoidal category

  """
  @spec mplus(Monoid.t, Monoid.t) :: Monoid.t
  def mplus(x, y)

  @doc """
  The left and right identity of `mplus`

  """
  @spec identity(Monoid.t) :: Monoid.t
  def identity(x)
end

defimpl Monoid, for: List do
  def mplus(x, y), do: x ++ y
  def identity(_), do: []
end

defimpl Monoid, for: Map do
  defdelegate mplus(x, y), to: Map, as: :merge
  def identity(_), do: %{}
end
