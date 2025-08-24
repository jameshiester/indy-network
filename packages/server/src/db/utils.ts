import {
  MongoQueryParser,
  allParsingInstructions,
  MongoQuery,
} from '@ucast/mongo';
import { interpret } from '@ucast/sql/typeorm';
import { Repository } from 'typeorm';

const parser = new MongoQueryParser(allParsingInstructions);

const findAndCount = async <TEntity>(
  repository: Repository<TEntity>,
  filter: MongoQuery<TEntity>,
  offset?: number,
  limit?: number,
) => {
  const ast = parser.parse(filter);
  const condition = interpret(ast, repository.createQueryBuilder('a'));
  const query = repository.createQueryBuilder('a').where(condition);
  if (offset) {
    query.skip(offset);
  }
  if (limit) {
    query.take(limit);
  }
  const [results, totalRecords] = await query.getManyAndCount();
  return { results, totalRecords };
};

export { findAndCount };
