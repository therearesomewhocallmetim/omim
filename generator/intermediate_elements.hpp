#pragma once

#include "base/assert.hpp"
#include "base/std_serialization.hpp"

#include "coding/reader.hpp"
#include "coding/varint.hpp"
#include "coding/writer.hpp"

#include "std/algorithm.hpp"
#include "std/bind.hpp"
#include "std/limits.hpp"
#include "std/string.hpp"
#include "std/utility.hpp"
#include "std/vector.hpp"

struct WayElement
{
  vector<uint64_t> nodes;
  uint64_t m_wayOsmId;

  explicit WayElement(uint64_t osmId) : m_wayOsmId(osmId) {}

  bool IsValid() const { return !nodes.empty(); }

  uint64_t GetOtherEndPoint(uint64_t id) const
  {
    if (id == nodes.front())
      return nodes.back();

    ASSERT(id == nodes.back(), ());
    return nodes.front();
  }

  template <class ToDo>
  void ForEachPoint(ToDo & toDo) const
  {
    for_each(nodes.begin(), nodes.end(), ref(toDo));
  }

  template <class ToDo>
  void ForEachPointOrdered(uint64_t start, ToDo && toDo)
  {
    ASSERT(!nodes.empty(), ());
    if (start == nodes.front())
      for_each(nodes.begin(), nodes.end(), ref(toDo));
    else
      for_each(nodes.rbegin(), nodes.rend(), ref(toDo));
  }

  template <class TWriter>
  void Write(TWriter & writer) const
  {
    uint64_t count = nodes.size();
    WriteVarUint(writer, count);
    for (uint64_t e : nodes)
      WriteVarUint(writer, e);
  }

  template <class TReader>
  void Read(TReader & reader)
  {
    ReaderSource<MemReader> r(reader);
    uint64_t count = ReadVarUint<uint64_t>(r);
    nodes.resize(count);
    for (uint64_t & e : nodes)
      e = ReadVarUint<uint64_t>(r);
  }

  string ToString() const
  {
    stringstream ss;
    ss << nodes.size() << " " << m_wayOsmId;
    return ss.str();
  }

  string Dump() const
  {
    stringstream ss;
    for (auto const & e : nodes)
      ss << e << ";";
    return ss.str();
  }
};

class RelationElement
{
public:
  using TMembers = vector<pair<uint64_t, string>>;

  TMembers nodes;
  TMembers ways;
  map<string, string> tags;

  bool IsValid() const { return !(nodes.empty() && ways.empty()); }

  string GetType() const
  {
    auto it = tags.find("type");
    return ((it != tags.end()) ? it->second : string());
  }

  bool FindWay(uint64_t id, string & role) const { return FindRoleImpl(ways, id, role); }
  bool FindNode(uint64_t id, string & role) const { return FindRoleImpl(nodes, id, role); }

  template <class ToDo>
  void ForEachWay(ToDo & toDo) const
  {
    for (size_t i = 0; i < ways.size(); ++i)
      toDo(ways[i].first, ways[i].second);
  }

  void Swap(RelationElement & rhs)
  {
    nodes.swap(rhs.nodes);
    ways.swap(rhs.ways);
    tags.swap(rhs.tags);
  }

  template <class TWriter>
  void Write(TWriter & writer) const
  {
    auto StringWriter = [&writer, this](string const & str)
    {
      CHECK_LESS(str.size(), numeric_limits<uint16_t>::max(),
                 ("Can't store string greater then 65535 bytes", Dump()));
      uint16_t sz = static_cast<uint16_t>(str.size());
      writer.Write(&sz, sizeof(sz));
      writer.Write(str.data(), sz);
    };

    auto MembersWriter = [&writer, &StringWriter](TMembers const & members)
    {
      uint64_t count = members.size();
      WriteVarUint(writer, count);
      for (auto const & e : members)
      {
        // write id
        WriteVarUint(writer, e.first);
        // write role
        StringWriter(e.second);
      }
    };

    MembersWriter(nodes);
    MembersWriter(ways);

    uint64_t count = tags.size();
    WriteVarUint(writer, count);
    for (auto const & e : tags)
    {
      // write key
      StringWriter(e.first);
      // write value
      StringWriter(e.second);
    }
  }

  template <class TReader>
  void Read(TReader & reader)
  {
    ReaderSource<TReader> r(reader);

    auto StringReader = [&r](string & str)
    {
      uint16_t sz = 0;
      r.Read(&sz, sizeof(sz));
      str.resize(sz);
      r.Read(&str[0], sz);
    };

    auto MembersReader = [&r, &StringReader](TMembers & members)
    {
      uint64_t count = ReadVarUint<uint64_t>(r);
      members.resize(count);
      for (auto & e : members)
      {
        // decode id
        e.first = ReadVarUint<uint64_t>(r);
        // decode role
        StringReader(e.second);
      }
    };

    MembersReader(nodes);
    MembersReader(ways);

    // decode tags
    tags.clear();
    uint64_t count = ReadVarUint<uint64_t>(r);
    for (uint64_t i = 0; i < count; ++i)
    {
      pair<string, string> kv;
      // decode key
      StringReader(kv.first);
      // decode value
      StringReader(kv.second);
      tags.emplace(kv);
    }
  }

  string ToString() const
  {
    stringstream ss;
    ss << nodes.size() << " " << ways.size() << " " << tags.size();
    return ss.str();
  }

  string Dump() const
  {
    stringstream ss;
    for (auto const & e : nodes)
      ss << "n{" << e.first << "," << e.second << "};";
    for (auto const & e : ways)
      ss << "w{" << e.first << "," << e.second << "};";
    for (auto const & e : tags)
      ss << "t{" << e.first << "," << e.second << "};";
    return ss.str();
  }

protected:
  bool FindRoleImpl(TMembers const & container, uint64_t id, string & role) const
  {
    for (auto const & e : container)
    {
      if (e.first == id)
      {
        role = e.second;
        return true;
      }
    }
    return false;
  }
};
