﻿using System;
using System.Linq.Expressions;
using LinqToDB.Expressions;
using LinqToDB.SqlQuery;

namespace LinqToDB.Linq.Parser
{
	public class SelectQueryExpression : BaseCustomExpression
	{
		public SelectQuery SelectQuery { get; }
		public Type ItemType { get; }
		public const ExpressionType ExpressionType = (ExpressionType) 200003;

		public SelectQueryExpression(SelectQuery selectQuery, Type itemType)
		{
			SelectQuery = selectQuery;
			ItemType = itemType;
		}

		public override ExpressionType NodeType => ExpressionType;
		public override Type Type => ItemType;

		public override string ToString ()
		{
			return $"Select({ItemType.Name})";
		}

		public override void CustomVisit(Action<Expression> func)
		{
			func(this);
		}

		public override bool CustomVisit(Func<Expression, bool> func)
		{
			return func(this);
		}

		public override Expression CustomFind(Func<Expression, bool> func)
		{
			if (func(this))
				return this;
			return null;
		}

		public override Expression CustomTransform(Func<Expression, Expression> func)
		{
			return func(this);
		}

		public override bool CustomEquals(Expression other)
		{
			if (other.GetType() != GetType())
				return false;

			var otherExpr = (SelectQueryExpression)other;
			return (otherExpr.SelectQuery == SelectQuery) && (otherExpr.ItemType == ItemType);
		}
	}
}